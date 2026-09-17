#!/usr/bin/env zsh

# ============================================================
#  pull-all.sh —— 批量拉取所有配置仓库
#
#  用法 : ./pull-all.sh
#  特性 : 彩色输出 · 进度编号 · 旋转动画 · 成功/失败统计 · 自动识别裸仓库
#         有未提交变更时先 fetch 比较，远程无更新不误报失败
# ============================================================

setopt NO_BG_NICE 2>/dev/null

# ── 颜色（非终端输出时自动禁用）──────────────────────────────
if [[ -t 1 ]]; then
  R=$'\033[0m';  B=$'\033[1m';  D=$'\033[2m'
  RED=$'\033[31m';  GREEN=$'\033[32m';  YELLOW=$'\033[33m'
  CYAN=$'\033[36m'; MAGENTA=$'\033[35m'; GRAY=$'\033[90m'
else
  R=''; B=''; D=''
  RED=''; GREEN=''; YELLOW=''; CYAN=''; MAGENTA=''; GRAY=''
fi

REPOS=(
  ~/bin
  ~/.config
  ~/.config/nvim
  ~/.emacs.spacemacs.d
  ~/.spacezsh
  ~/.oh-my-zsh
  ~/.tmux
  ~/.fzf
  ~/.agents
  ~/global-claude
  ~/icloud-repos/journal.git
  ~/icloud-repos/snippets.git
  ~/icloud-repos/webclips.git
  ~/icloud-repos/notes.git
  ~/icloud-repos/books.git
)

# 画一条全宽分隔线
hr() {
  local ch=$1 color=$2 n=${COLUMNS:-80} s="" i
  for ((i=0; i<n; i++)); do s+=$ch; done
  print -r -- "${color}${s}${R}"
}

# ── 信号与动画管理 ───────────────────────────────────────────
SPIN_PID=""
JOB_PID=""
tmpfile=""
rcfile=""
statefile=""

start_spinner() {
  (
    trap 'exit 0' INT TERM
    frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    i=0
    while :; do
      printf '\r  %s│%s  %s%s%s 拉取中…' "$CYAN" "$R" "$YELLOW" "${frames[((i % ${#frames}) + 1)]}" "$R"
      ((i++))
      sleep 0.1
    done
  ) &
  SPIN_PID=$!
}

stop_spinner() {
  if [[ -n "$SPIN_PID" ]]; then
    kill "$SPIN_PID" 2>/dev/null
    wait "$SPIN_PID" 2>/dev/null
    SPIN_PID=""
  fi
  printf '\r\033[K'
}

cleanup() {
  stop_spinner
  if [[ -n "$JOB_PID" ]]; then
    pkill -P "$JOB_PID" 2>/dev/null
    kill "$JOB_PID" 2>/dev/null
    wait "$JOB_PID" 2>/dev/null
    JOB_PID=""
  fi
  [[ -n "$tmpfile" && -f "$tmpfile" ]] && rm -f "$tmpfile" 2>/dev/null
  [[ -n "$rcfile" && -f "$rcfile" ]] && rm -f "$rcfile" 2>/dev/null
  [[ -n "$statefile" && -f "$statefile" ]] && rm -f "$statefile" 2>/dev/null
  tmpfile=""
  rcfile=""
  statefile=""
  printf '\r\033[K'
}

handle_sigint() {
  cleanup
  print ""
  hr '━' "$RED"
  print "  ${RED}${B}✘ 操作已由用户终止 (Ctrl-C)${R}"
  hr '━' "$RED"
  print ""
  exit 130
}

trap 'handle_sigint' INT TERM

# ── 单仓库拉取 ───────────────────────────────────────────────
# 结果写入文件：$3 输出 · $4 退出码 · $5 状态
# 状态: updated 有更新 / synced 裸仓库已同步 / up_to_date 已是最新
#       no_update 有未提交变更但远程无更新 / failed 失败
do_pull() {
  local repo=$1 is_bare=$2 outfile=$3 rcfile=$4 statefile=$5
  local out="" rc=0 state="failed" counts behind

  if [[ "$is_bare" == "true" ]]; then
    out=$(git -C "$repo" fetch --all --prune 2>&1); rc=$?
    (( rc == 0 )) && state="synced"
  elif [[ -n "$(git -C "$repo" status --porcelain --untracked-files=no 2>/dev/null)" ]]; then
    # 工作区有未提交变更：先 fetch 远程，再比较远程分支与本地 HEAD，
    # 远程没有新提交就不算失败（避免被 pull --rebase 拒绝而误报）
    out=$(git -C "$repo" fetch --all --prune 2>&1); rc=$?
    if (( rc == 0 )); then
      counts=$(git -C "$repo" rev-list --left-right --count "HEAD...@{upstream}" 2>/dev/null)
      behind="${counts##*$'\t'}"
      if [[ -z "$behind" ]]; then
        # 没有上游分支，回退为普通 pull，保留 git 自身的报错信息
        out=$(cd "$repo" && git pull 2>&1); rc=$?
        if (( rc == 0 )); then
          if [[ "$out" == *"Already up to date."* || "$out" == *"是最新的"* ]]; then
            state="up_to_date"
          else
            state="updated"
          fi
        fi
      elif (( behind == 0 )); then
        state="no_update"           # 远程与 HEAD 一致（或仅本地领先），无需拉取
      else
        [[ -n "$out" ]] && out+=$'\n'
        out+="错误：远程分支有新提交，但工作区有未提交的变更，无法自动拉取。"
        out+=$'\n'"请先提交或储藏 (stash) 本地修改后再拉取。"
        rc=1; state="failed"
      fi
    fi
  else
    out=$(cd "$repo" && git pull 2>&1); rc=$?
    if (( rc == 0 )); then
      if [[ "$out" == *"Already up to date."* || "$out" == *"是最新的"* ]]; then
        state="up_to_date"
      else
        state="updated"
      fi
    fi
  fi

  print -r -- "$out" > "$outfile"
  print -r -- "$rc" > "$rcfile"
  print -r -- "$state" > "$statefile"
}

main() {
  local total=${#REPOS[@]} i=1
  local ok=0 up_to_date=0 skip=0 fail=0
  local repo idx branch branch_str output rc state prefix is_bare use_spinner

  print ""
  hr '━' "$CYAN"
  print "  ${B}${CYAN}⚡ Pull-All${R}  ·  批量拉取 ${B}${total}${R} 个 Git 仓库"
  print "  ${GRAY}${D}$(date '+%Y-%m-%d %H:%M:%S')${R}"
  hr '━' "$CYAN"
  print ""

  for repo in "${REPOS[@]}"; do
    repo="${repo/#\~/$HOME}"                        # 展开 ~/ → $HOME
    idx=$(printf '%02d/%02d' "$i" "$total"); ((i++))

    # 判断是否为 git 仓库
    if ! git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
      print "  ${YELLOW}┌── ${B}⚠ ${idx}${R} ${YELLOW}${B}${repo}${R} ${GRAY}· 不是 Git 仓库${R}"
      print "  ${YELLOW}└── ⚠ 已跳过${R}"
      print ""
      ((skip++))
      continue
    fi

    is_bare=false
    [[ "$(git -C "$repo" rev-parse --is-bare-repository 2>/dev/null)" == "true" ]] && is_bare=true

    if [[ "$is_bare" == "false" ]]; then
      branch=$(cd "$repo" && git branch --show-current 2>/dev/null)
      branch_str=""
      [[ -n "$branch" ]] && branch_str=" ${MAGENTA}· ${branch}${R}"
    else
      branch_str=" ${GRAY}· 裸仓库${R}"
    fi

    print "  ${CYAN}┌── ${B}🔄 ${idx}${R} ${B}${repo}${R}${branch_str}"

    # 裸仓库用 fetch 同步；普通仓库用 pull，有未提交变更时先 fetch 再比较
    use_spinner=false
    [[ -t 1 ]] && use_spinner=true

    tmpfile=$(mktemp); rcfile=$(mktemp); statefile=$(mktemp)
    if [[ "$use_spinner" == "true" ]]; then
      # 后台执行，前台旋转动画
      start_spinner
      (
        trap - INT TERM
        do_pull "$repo" "$is_bare" "$tmpfile" "$rcfile" "$statefile"
      ) &
      JOB_PID=$!
      wait "$JOB_PID" 2>/dev/null
      JOB_PID=""
      stop_spinner
    else
      do_pull "$repo" "$is_bare" "$tmpfile" "$rcfile" "$statefile"
    fi
    rc=$(<"$rcfile")
    state=$(<"$statefile")
    output=$(<"$tmpfile")
    rm -f "$tmpfile" "$rcfile" "$statefile" 2>/dev/null
    tmpfile=""; rcfile=""; statefile=""
    output="${output%"${output##*[![:space:]]}"}"  # 去掉末尾空白行

    # 打印 git 输出（失败时标红）
    if [[ -n "$output" ]]; then
      prefix=$GRAY
      [[ "$state" == "failed" ]] && prefix=$RED
      print -r -- "$output" | sed "s/^/  ${CYAN}│${R}  ${prefix}/"
    fi

    case "$state" in
      updated)      print "  ${GREEN}└── ${B}✅ 拉取成功 · 有更新${R}";     ((ok++)) ;;
      synced)       print "  ${GREEN}└── ${B}✅ 同步成功${R}";              ((ok++)) ;;
      up_to_date)   print "  ${GRAY}└── ✔ 已是最新${R}";                   ((up_to_date++)) ;;
      no_update)    print "  ${GRAY}└── ✔ 没有更新${R}";                   ((up_to_date++)) ;;
      failed)       print "  ${RED}└── ${B}✘ 拉取失败${R}";                ((fail++)) ;;
    esac
    print ""
  done

  # ── 汇总 ──
  hr '━' "$CYAN"
  print "  ${B}${CYAN}📊 汇总${R}"
  local summary=()
  (( ok > 0 ))         && summary+=("${GREEN}✅ 有更新/已同步: ${ok}${R}")
  summary+=("${GRAY}✔ 已是最新: ${up_to_date}${R}")
  (( skip > 0 ))       && summary+=("${YELLOW}⚠ 跳过: ${skip}${R}")
  (( fail > 0 ))       && summary+=("${RED}✘ 失败: ${fail}${R}")
  print "  ${(j:   :)summary}"
  if (( fail > 0 )); then
    print "  ${RED}${B}！！ ${fail} 个仓库拉取失败，请检查上方错误信息${R}"
  else
    print "  ${GREEN}${B}🎉 全部仓库处理完毕，一切正常！${R}"
  fi
  hr '━' "$CYAN"
  print ""

  (( fail > 0 )) && return 1
  return 0
}

main "$@"

