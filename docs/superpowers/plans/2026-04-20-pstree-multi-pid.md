# pstree 多 PID 支持实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 重写 `pstree` bash 脚本，支持多 PID 参数，使用进程池方案合并展示共享祖先的进程树。

**Architecture:** 一次 `ps` 调用获取全部进程数据，在内存中构建 PPID/CMD/CHILDREN 关联数组。对多个目标 PID 计算祖先路径、LCA 分组、标记集合，最后渲染裁剪后的树。单 PID 和多 PID 统一走同一套逻辑。

**Tech Stack:** Bash 4+（关联数组），`ps`，`awk`，macOS/Linux 兼容

---

## 文件结构

- **Modify:** `/Users/liuxiang/bin/pstree` — 唯一文件，完全重写

---

### Task 1: 脚本骨架 — 参数解析与验证

**Files:**
- Modify: `/Users/liuxiang/bin/pstree` (complete rewrite)

- [ ] **Step 1: 写参数解析与验证骨架**

替换整个 `/Users/liuxiang/bin/pstree` 为：

```bash
#!/bin/bash

# 用法: pstree <PID> [PID2] [PID3] ...
# 兼容 macOS 和 Linux

set -euo pipefail

# 颜色定义
RED='\033[1;31m'
RESET='\033[0m'

# 用法检查
if [ $# -eq 0 ]; then
  echo "用法: $0 <PID> [PID2] [PID3] ..." >&2
  exit 1
fi

# 收集并验证目标 PID（去重、过滤 PID 0、检查是否存在）
TARGET_PIDS=()
declare -A seen_pid
for arg in "$@"; do
  # PID 0 不支持
  if [ "$arg" = "0" ]; then
    echo "pstree: 进程号 0 不支持，已跳过" >&2
    continue
  fi

  # 去重
  if [ -n "${seen_pid[$arg]+_}" ]; then
    continue
  fi
  seen_pid[$arg]=1

  # 检查是否存在
  if ! ps -p "$arg" >/dev/null 2>&1; then
    echo "pstree: 进程号 $arg 不存在，已跳过" >&2
    continue
  fi

  TARGET_PIDS+=("$arg")
done

if [ ${#TARGET_PIDS[@]} -eq 0 ]; then
  echo "pstree: 没有有效的进程号" >&2
  exit 1
fi
```

- [ ] **Step 2: 测试参数解析**

```bash
# 无参数应报错
bash pstree; echo "exit: $?"

# 不存在的 PID 应警告
bash pstree 99999999; echo "exit: $?"

# PID 0 应警告
bash pstree 0; echo "exit: $?"

# 单个有效 PID（当前 shell）
bash pstree $$
```

预期：前三个退出码为 1，最后一个退出码为 0（无输出但无报错）。

- [ ] **Step 3: 提交**

```bash
git add pstree
git commit -m "pstree: 重写参数解析，支持多 PID、去重、PID 0 过滤"
```

---

### Task 2: 进程池数据收集与子进程索引

**Files:**
- Modify: `/Users/liuxiang/bin/pstree` (append after validation block)

- [ ] **Step 1: 添加进程池收集与 CHILDREN 索引**

在 `TARGET_PIDS` 验证块之后、脚本结尾之前追加：

```bash
# 一次性获取全部进程数据
declare -A PPID_MAP
declare -A CMD_MAP
declare -A CHILDREN

while IFS= read -r line; do
  pid=$(echo "$line" | awk '{print $1}')
  ppid=$(echo "$line" | awk '{print $2}')
  cmd=$(echo "$line" | awk '{$1=""; $2=""; sub(/^  */, ""); print}')
  PPID_MAP[$pid]=$ppid
  CMD_MAP[$pid]=$cmd
  # 追加到父进程的子列表（空格分隔）
  if [ -n "${CHILDREN[$ppid]+_}" ]; then
    CHILDREN[$ppid]="${CHILDREN[$ppid]} $pid"
  else
    CHILDREN[$ppid]="$pid"
  fi
done < <(ps -eo pid=,ppid=,args=)

# 格式化进程信息
format_proc() {
  local pid=$1
  echo "${pid} • ${PPID_MAP[$pid]} • ${CMD_MAP[$pid]}"
}
```

- [ ] **Step 2: 验证数据收集**

在脚本末尾临时添加调试输出：

```bash
# 临时调试：验证数据收集
echo "PPID_MAP 条目数: ${#PPID_MAP[@]}"
echo "PID 1 的命令: ${CMD_MAP[1]}"
echo "PID 1 的子进程: ${CHILDREN[1]}"
```

运行 `bash pstree $$`，确认输出非空且合理，然后删除调试代码。

- [ ] **Step 3: 提交**

```bash
git add pstree
git commit -m "pstree: 添加进程池数据收集与子进程索引"
```

---

### Task 3: 祖先追溯（含环检测）

**Files:**
- Modify: `/Users/liuxiang/bin/pstree` (append after data collection)

- [ ] **Step 1: 添加祖先追溯函数**

在 `format_proc` 函数之后追加：

```bash
# 追溯祖先路径（从 target 到 PID 1，含环检测）
# 输出: "1 pid1 pid2 ... target"（空格分隔）
trace_ancestors() {
  local target=$1
  local path=()
  declare -A visited
  local pid=$target

  while [ -n "$pid" ] && [ "$pid" != "0" ]; do
    # 环检测
    if [ -n "${visited[$pid]+_}" ]; then
      break
    fi
    visited[$pid]=1
    path=("$pid" "${path[@]}")

    # 向上追溯
    if [ "$pid" = "1" ]; then
      break
    fi
    pid=${PPID_MAP[$pid]:-}
    if [ -z "$pid" ]; then
      break
    fi
  done

  # 确保从 PID 1 开始
  if [ "${path[0]}" != "1" ] && [ -n "${PPID_MAP[1]+_}" ]; then
    path=("1" "${path[@]}")
  fi

  echo "${path[@]}"
}
```

- [ ] **Step 2: 测试祖先追溯**

在脚本末尾临时添加：

```bash
# 临时调试
for pid in "${TARGET_PIDS[@]}"; do
  echo "PID $pid 的祖先路径: $(trace_ancestors $pid)"
done
```

运行 `bash pstree $$`，确认路径从 1 开始到 `$$` 结束。然后删除调试代码。

- [ ] **Step 3: 提交**

```bash
git add pstree
git commit -m "pstree: 添加祖先追溯函数（含环检测）"
```

---

### Task 4: LCA 计算与分组

**Files:**
- Modify: `/Users/liuxiang/bin/pstree` (append after trace_ancestors)

- [ ] **Step 1: 添加 LCA 计算与分组逻辑**

在 `trace_ancestors` 函数之后追加：

```bash
# 计算多条祖先路径的最低公共祖先（LCA）
# 返回 LCA 的 PID；如果只有 PID 1 共同，返回 1
compute_lca() {
  # $@: 各条祖先路径（每条为 "1 a b c" 格式）
  local paths=("$@")
  local first="${paths[0]}"

  # 单条路径，LCA 就是路径最后一个（目标本身）
  if [ ${#paths[@]} -eq 1 ]; then
    echo "$first"
    return
  fi

  # 将第一条路径转为有序数组
  read -ra first_arr <<< "$first"

  # 从最深到最浅，找第一个在所有路径中出现的节点
  for (( i=${#first_arr[@]}-1; i>=0; i-- )); do
    local candidate="${first_arr[$i]}"
    local in_all=1
    for (( j=1; j<${#paths[@]}; j++ )); do
      if [[ " ${paths[$j]} " != *" $candidate "* ]]; then
        in_all=0
        break
      fi
    done
    if [ "$in_all" -eq 1 ]; then
      echo "$candidate"
      return
    fi
  done

  echo "1"
}

# 对目标 PID 分组：LCA 不是 PID 1 的为同组，否则独立
# 输出: 每行一组，每行是空格分隔的 PID 列表
group_by_lca() {
  local target_pids=("$@")

  # 单个 PID，直接返回
  if [ ${#target_pids[@]} -eq 1 ]; then
    echo "${target_pids[0]}"
    return
  fi

  # 获取所有祖先路径
  local paths=()
  for pid in "${target_pids[@]}"; do
    paths+=("$(trace_ancestors "$pid")")
  done

  # 计算 LCA
  local lca
  lca=$(compute_lca "${paths[@]}")

  # LCA 为 PID 1（且不止一个目标），则各自独立
  if [ "$lca" = "1" ]; then
    for pid in "${target_pids[@]}"; do
      echo "$pid"
    done
    return
  fi

  # 有共同祖先，合并为一组
  echo "${target_pids[@]}"
}
```

- [ ] **Step 2: 测试分组逻辑**

在脚本末尾临时添加：

```bash
# 临时调试
groups=$(group_by_lca "${TARGET_PIDS[@]}")
while IFS= read -r group; do
  echo "组: $group"
done <<< "$groups"
```

测试：
- `bash pstree $$` → 单组，含当前 shell PID
- `bash pstree $$ 1` → 应合并为一组（1 是 $$ 的祖先）

然后删除调试代码。

- [ ] **Step 3: 提交**

```bash
git add pstree
git commit -m "pstree: 添加 LCA 计算与分组逻辑"
```

---

### Task 5: 标记集合与树渲染

**Files:**
- Modify: `/Users/liuxiang/bin/pstree` (append after grouping, replace remaining main logic)

- [ ] **Step 1: 添加标记集合构建与树渲染**

在 `group_by_lca` 函数之后追加，作为主逻辑：

```bash
# 构建标记集合：目标 PID + 每个目标从 LCA 到自身的路径上的所有 PID
# $1: LCA PID
# $@: remaining args are target PIDs
build_marked_set() {
  local lca=$1
  shift
  local targets=("$@")
  declare -A marked

  for target in "${targets[@]}"; do
    local path=$(trace_ancestors "$target")
    read -ra path_arr <<< "$path"
    local found_lca=0
    for pid in "${path_arr[@]}"; do
      if [ "$pid" = "$lca" ]; then
        found_lca=1
      fi
      if [ "$found_lca" -eq 1 ]; then
        marked[$pid]=1
      fi
    done
  done

  # 输出标记集合（空格分隔）
  echo "${!marked[@]}"
}

# 检查 PID 是否在标记集合中
is_marked() {
  local pid=$1
  [[ " $MARKED_STR " == *" $pid "* ]]
}

# 高亮目标 PID
print_node() {
  local pid=$1
  local info
  info=$(format_proc "$pid")

  # 检查是否为目标 PID
  local is_target=0
  for t in "${TARGET_PIDS[@]}"; do
    if [ "$pid" = "$t" ]; then
      is_target=1
      break
    fi
  done

  if [ "$is_target" -eq 1 ]; then
    echo -e "${RED}${info}${RESET}"
  else
    echo "$info"
  fi
}

# 渲染祖先链（从 PID 1 到 lca，全是单子节点直链）
# 参数: ancestors 数组（全局），截止到 lca
# 输出祖先链，返回累积的 prefix
render_ancestor_chain() {
  local start_idx=$1
  local end_idx=$2
  local prefix=""

  for (( i=start_idx; i<=end_idx; i++ )); do
    local pid="${ANCESTOR_CHAIN[$i]}"

    if [ "$i" -eq "$start_idx" ]; then
      echo -n ""
      print_node "$pid"
    else
      echo -n "${prefix}└── "
      print_node "$pid"
    fi
    prefix+="    "
  done

  echo "$prefix"
}

# 渲染子树（从指定 PID 向下，只渲染标记集合中的节点）
render_subtree() {
  local pid=$1
  local prefix=$2

  local children_str="${CHILDREN[$pid]:-}"
  [ -z "$children_str" ] && return

  # 筛选标记集合中的子节点
  local marked_children=()
  for child in $children_str; do
    if is_marked "$child"; then
      marked_children+=("$child")
    fi
  done

  local count=${#marked_children[@]}
  local i=0

  for child in "${marked_children[@]}"; do
    i=$((i+1))
    local branch="├── "
    local next_prefix="│   "

    if [ "$i" -eq "$count" ]; then
      branch="└── "
      next_prefix="    "
    fi

    echo -n "$prefix$branch"
    print_node "$child"
    render_subtree "$child" "$prefix$next_prefix"
  done
}

# ============ 主渲染逻辑 ============

first_group=1
groups=$(group_by_lca "${TARGET_PIDS[@]}")

while IFS= read -r group; do
  [ -z "$group" ] && continue

  # 组间空行
  if [ "$first_group" -eq 1 ]; then
    first_group=0
  else
    echo ""
  fi

  read -ra group_pids <<< "$group"

  # 单 PID 组
  if [ ${#group_pids[@]} -eq 1 ]; then
    local_target="${group_pids[0]}"
    local_lca="$local_target"
    MARKED_STR=$(build_marked_set "$local_lca" "$local_target")
  else
    # 多 PID 组，计算 LCA
    local_paths=()
    for p in "${group_pids[@]}"; do
      local_paths+=("$(trace_ancestors "$p")")
    done
    local_lca=$(compute_lca "${local_paths[@]}")
    MARKED_STR=$(build_marked_set "$local_lca" "${group_pids[@]}")
  fi

  # 获取 LCA 的祖先链
  local_ancestor_path=$(trace_ancestors "$local_lca")
  read -ra ANCESTOR_CHAIN <<< "$local_ancestor_path"

  # 找到 LCA 在祖先链中的索引
  local_lca_idx=-1
  for (( i=0; i<${#ANCESTOR_CHAIN[@]}; i++ )); do
    if [ "${ANCESTOR_CHAIN[$i]}" = "$local_lca" ]; then
      local_lca_idx=$i
      break
    fi
  done

  # 渲染祖先链（PID 1 到 LCA）
  prefix=$(render_ancestor_chain 0 "$local_lca_idx")

  # 从 LCA 向下渲染标记集合中的子树
  render_subtree "$local_lca" "$prefix"
done <<< "$groups"
```

- [ ] **Step 2: 端到端测试**

```bash
# 单 PID — 应与旧行为一致（祖先链 + 后代树）
bash pstree $$

# 多 PID 共享祖先
# 找两个同父进程测试，或直接用当前 shell 和其父进程
bash pstree $$ $PPID

# 多 PID 无共同祖先（PID 1 和一个普通进程）
bash pstree 1 $$

# 不存在的 PID 混合有效 PID
bash pstree $$ 99999999

# 重复 PID
bash pstree $$ $$

# 当前 shell 的完整进程树
bash pstree $$
```

逐项确认输出格式正确、高亮正确、分组正确。

- [ ] **Step 3: 提交**

```bash
git add pstree
git commit -m "pstree: 添加标记集合构建与树渲染，完成多 PID 支持"
```

---

### Task 6: 清理与最终验证

**Files:**
- Modify: `/Users/liuxiang/bin/pstree` (cleanup)

- [ ] **Step 1: 清理代码**

- 删除所有临时调试代码（如有残留）
- 确认脚本开头的注释已更新为 `# 用法: pstree <PID> [PID2] [PID3] ...`
- 确认 `set -euo pipefail` 在位
- 检查所有函数顺序正确（先定义后使用）

- [ ] **Step 2: 最终验证**

```bash
# macOS 兼容测试
bash pstree $$

# 无参数
bash pstree; echo "exit=$?"

# 全部无效 PID
bash pstree 99999999 88888888; echo "exit=$?"

# PID 0
bash pstree 0; echo "exit=$?"

# 多 PID 混合场景
bash pstree $$ 1
bash pstree $$ $$ $PPID
```

所有场景输出符合 spec 预期。

- [ ] **Step 3: 最终提交**

```bash
git add pstree
git commit -m "pstree: 清理并完成多 PID 支持"
```

---

## 自审清单

**1. Spec 覆盖度：**
- CLI 接口（多 PID、去重、PID 0 过滤、存在性检查）→ Task 1
- 进程池数据收集（PPID_MAP, CMD_MAP, CHILDREN）→ Task 2
- 祖先追溯含环检测 → Task 3
- LCA 计算与分组 → Task 4
- 标记集合构建 → Task 5
- 树渲染（祖先链 + 裁剪子树 + 高亮）→ Task 5
- 独立组空行分隔 → Task 5
- 输出格式 PID • PPID • CMD → Task 2 (format_proc)
- macOS/Linux 兼容 → `ps -eo pid=,ppid=,args=` 两者通用

**2. 占位符扫描：** 无 TBD/TODO/实现稍后。所有步骤含完整代码。

**3. 一致性检查：**
- `PPID_MAP`、`CMD_MAP`、`CHILDREN` 在 Task 2 定义，后续所有 Task 使用同一命名
- `TARGET_PIDS` 在 Task 1 定义，全局使用
- `MARKED_STR` 在 Task 5 定义为全局变量，`is_marked` 函数使用它
- `ANCESTOR_CHAIN` 在 Task 5 主逻辑中定义为全局，`render_ancestor_chain` 使用它
- `format_proc` 在 Task 2 定义，Task 5 的 `print_node` 调用它
- `trace_ancestors` 在 Task 3 定义，Task 4/5 调用它
- `compute_lca` 在 Task 4 定义，Task 5 调用它
- `group_by_lca` 在 Task 4 定义，Task 5 调用它
