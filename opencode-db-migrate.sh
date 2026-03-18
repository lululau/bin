#!/bin/bash
#
# OpenCode 项目数据迁移脚本
# 用于导出/导入指定项目的全部 session 数据
#
# 用法:
#   导出: ./opencode-db-migrate.sh export ~/projects/myproject
#   导入: ./opencode-db-migrate.sh import ./myproject-export.sql
#

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认数据库路径
DEFAULT_DB="$HOME/.local/share/opencode/opencode.db"

# 帮助信息
show_help() {
    cat << EOF
OpenCode 项目数据迁移脚本

用法:
  $0 export <项目路径> [输出文件]    导出指定项目的全部数据
  $0 import <sql文件>               从 SQL 文件导入数据
  $0 list                           列出所有项目及其 session 数量
  $0 info <项目路径>                显示指定项目的详细信息

选项:
  -d, --db <数据库路径>    指定数据库文件路径 (默认: ~/.local/share/opencode/opencode.db)
  -f, --force              导入时强制覆盖已存在的数据
  -h, --help               显示此帮助信息

示例:
  # 导出 ~/projects/myproject 的所有数据
  $0 export ~/projects/myproject

  # 导出到指定文件
  $0 export ~/projects/myproject ./myproject-backup.sql

  # 从 SQL 文件导入
  $0 import ./myproject-backup.sql

  # 列出所有项目
  $0 list

  # 查看项目详情
  $0 info ~/projects/myproject

注意:
  - 导入前请确保 OpenCode 未在运行
  - 导入会追加数据，使用 --force 会先删除已存在的数据
EOF
}

# 打印带颜色的消息
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查数据库是否存在
check_db() {
    local db_path="$1"
    if [[ ! -f "$db_path" ]]; then
        log_error "数据库文件不存在: $db_path"
        exit 1
    fi
}

# 检查 sqlite3 是否可用
check_sqlite() {
    if ! command -v sqlite3 &> /dev/null; then
        log_error "sqlite3 未安装，请先安装 sqlite3"
        exit 1
    fi
}

# 列出所有项目
cmd_list() {
    local db_path="$1"
    check_db "$db_path"
    
    echo ""
    echo "项目列表:"
    echo "========================================="
    sqlite3 "$db_path" -cmd ".mode column" -cmd ".headers on" \
        "SELECT 
            p.id AS project_id,
            p.name AS project_name,
            p.worktree AS path,
            COUNT(DISTINCT s.id) AS sessions,
            COUNT(DISTINCT m.id) AS messages
        FROM project p
        LEFT JOIN session s ON s.project_id = p.id
        LEFT JOIN message m ON m.session_id = s.id
        GROUP BY p.id
        ORDER BY p.time_created DESC;"
    echo ""
}

# 显示项目详情
cmd_info() {
    local db_path="$1"
    local project_path="$2"
    
    check_db "$db_path"
    
    # 标准化路径
    project_path=$(cd "$project_path" 2>/dev/null && pwd || echo "$project_path")
    
    # 查找项目 (优先精确匹配)
    local project_info
    project_info=$(sqlite3 "$db_path" \
        "SELECT id, name, worktree FROM project WHERE worktree = '$project_path' LIMIT 1;")
    
    if [[ -z "$project_info" ]]; then
        project_info=$(sqlite3 "$db_path" \
            "SELECT id, name, worktree FROM project WHERE worktree LIKE '%${project_path}%' LIMIT 1;")
    fi
    
    if [[ -z "$project_info" ]]; then
        log_error "未找到项目: $project_path"
        log_info "使用 '$0 list' 查看所有项目"
        exit 1
    fi
    
    local project_id=$(echo "$project_info" | cut -d'|' -f1)
    local project_name=$(echo "$project_info" | cut -d'|' -f2)
    
    echo ""
    echo "项目详情:"
    echo "========================================="
    echo "ID:          $project_id"
    echo "名称:        $project_name"
    echo "路径:        $(echo "$project_info" | cut -d'|' -f3)"
    echo ""
    
    # Session 统计
    echo "Session 统计:"
    sqlite3 "$db_path" -cmd ".mode column" -cmd ".headers on" \
        "SELECT 
            COUNT(*) AS total_sessions,
            SUM(CASE WHEN parent_id IS NULL THEN 1 ELSE 0 END) AS root_sessions,
            SUM(CASE WHEN parent_id IS NOT NULL THEN 1 ELSE 0 END) AS child_sessions
        FROM session WHERE project_id = '$project_id';"
    echo ""
    
    # 消息统计
    echo "消息统计:"
    sqlite3 "$db_path" -cmd ".mode column" -cmd ".headers on" \
        "SELECT 
            COUNT(DISTINCT m.id) AS messages,
            COUNT(DISTINCT p.id) AS parts,
            COUNT(DISTINCT t.content) AS todos
        FROM session s
        LEFT JOIN message m ON m.session_id = s.id
        LEFT JOIN part p ON p.session_id = s.id
        LEFT JOIN todo t ON t.session_id = s.id
        WHERE s.project_id = '$project_id';"
    echo ""
}

# 导出项目数据
cmd_export() {
    local db_path="$1"
    local project_path="$2"
    local output_file="${3:-}"
    
    check_db "$db_path"
    check_sqlite
    
    # 标准化路径
    if [[ -d "$project_path" ]]; then
        project_path=$(cd "$project_path" && pwd)
    fi
    
    # 查找项目 (优先精确匹配)
    local project_id
    project_id=$(sqlite3 "$db_path" \
        "SELECT id FROM project WHERE worktree = '$project_path' LIMIT 1;")
    
    if [[ -z "$project_id" ]]; then
        project_id=$(sqlite3 "$db_path" \
            "SELECT id FROM project WHERE worktree LIKE '%${project_path}%' LIMIT 1;")
    fi
    
    if [[ -z "$project_id" ]]; then
        log_error "未找到项目: $project_path"
        log_info "使用 '$0 list' 查看所有项目"
        exit 1
    fi
    
    log_info "找到项目 ID: $project_id"
    
    # 生成输出文件名
    if [[ -z "$output_file" ]]; then
        local project_name
        project_name=$(sqlite3 "$db_path" "SELECT COALESCE(name, 'unnamed') FROM project WHERE id = '$project_id';")
        project_name=$(echo "$project_name" | tr ' ' '_' | tr -cd '[:alnum:]_-')
        output_file="./${project_name}-export-$(date +%Y%m%d-%H%M%S).sql"
    fi
    
    log_info "开始导出到: $output_file"
    
    # 创建临时文件
    local temp_file=$(mktemp)
    
    # 写入 SQL 头部
    {
        echo "-- OpenCode 项目数据导出"
        echo "-- 生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "-- 项目 ID: $project_id"
        echo ""
        echo "PRAGMA foreign_keys = OFF;"
        echo "BEGIN TRANSACTION;"
        echo ""
    } > "$temp_file"

    # 导出 project
    log_info "导出 project 表..."
    sqlite3 "$db_path" ".dump project" | grep "^INSERT INTO project" | grep "'$project_id'" >> "$temp_file" || true
    
    # 导出 permission
    log_info "导出 permission 表..."
    sqlite3 "$db_path" ".dump permission" | grep "^INSERT INTO permission" | grep "'$project_id'" >> "$temp_file" || true
    
    # 导出 workspace
    log_info "导出 workspace 表..."
    sqlite3 "$db_path" ".dump workspace" | grep "^INSERT INTO workspace" | grep "'$project_id'" >> "$temp_file" || true
    
    # 获取所有 session ID
    local session_ids
    session_ids=$(sqlite3 "$db_path" "SELECT id FROM session WHERE project_id = '$project_id';")
    
    if [[ -z "$session_ids" ]]; then
        log_warn "该项目没有 session 数据"
    else
        local session_count=$(echo "$session_ids" | wc -l | tr -d ' ')
        log_info "找到 $session_count 个 session"
        
        # 构建 session ID 匹配模式
        local session_pattern=$(echo "$session_ids" | tr '\n' '|' | sed 's/|$//')
        
        # 导出 session
        log_info "导出 session 表..."
        sqlite3 "$db_path" ".dump session" | grep "^INSERT INTO session" | grep -E "$session_pattern" >> "$temp_file" || true
        
        # 导出 message
        log_info "导出 message 表..."
        sqlite3 "$db_path" ".dump message" | grep "^INSERT INTO message" | grep -E "$session_pattern" >> "$temp_file" || true
        
        # 导出 part
        log_info "导出 part 表..."
        sqlite3 "$db_path" ".dump part" | grep "^INSERT INTO part" | grep -E "$session_pattern" >> "$temp_file" || true
        
        # 导出 todo
        log_info "导出 todo 表..."
        sqlite3 "$db_path" ".dump todo" | grep "^INSERT INTO todo" | grep -E "$session_pattern" >> "$temp_file" || true
        
        # 导出 session_share
        log_info "导出 session_share 表..."
        sqlite3 "$db_path" ".dump session_share" | grep "^INSERT INTO session_share" | grep -E "$session_pattern" >> "$temp_file" || true
    fi
    
    # 写入尾部
    cat >> "$temp_file" << 'SQLEOF'

COMMIT;
PRAGMA foreign_keys = ON;

-- 导出完成
SQLEOF

    # 移动到最终位置
    mv "$temp_file" "$output_file"
    
    local file_size=$(ls -lh "$output_file" | awk '{print $5}')
    log_success "导出完成: $output_file ($file_size)"
}

# 导入项目数据
cmd_import() {
    local db_path="$1"
    local sql_file="$2"
    local force="${3:-false}"
    
    check_sqlite
    
    if [[ ! -f "$sql_file" ]]; then
        log_error "SQL 文件不存在: $sql_file"
        exit 1
    fi
    
    # 检查数据库是否存在
    if [[ ! -f "$db_path" ]]; then
        log_warn "数据库文件不存在，将创建新数据库: $db_path"
        mkdir -p "$(dirname "$db_path")"
    fi
    
    # 提取项目 ID
    local project_id
    project_id=$(grep "项目 ID:" "$sql_file" | cut -d: -f2 | tr -d ' ')
    
    if [[ -z "$project_id" ]]; then
        log_warn "无法从 SQL 文件中提取项目 ID"
    else
        log_info "检测到项目 ID: $project_id"
        
        # 检查项目是否已存在
        local existing
        existing=$(sqlite3 "$db_path" "SELECT id FROM project WHERE id = '$project_id';" 2>/dev/null || true)
        
        if [[ -n "$existing" ]]; then
            if [[ "$force" == "true" ]]; then
                log_warn "项目已存在，将删除旧数据..."
                sqlite3 "$db_path" "PRAGMA foreign_keys = ON; DELETE FROM project WHERE id = '$project_id';"
            else
                log_error "项目已存在: $project_id"
                log_info "使用 --force 选项覆盖已存在的数据"
                exit 1
            fi
        fi
    fi
    
    # 检查 OpenCode 是否在运行
    if pgrep -f "opencode" &> /dev/null; then
        log_warn "检测到 OpenCode 可能正在运行"
        log_warn "建议先关闭 OpenCode 再导入数据"
        read -p "是否继续导入? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # 备份数据库
    local backup_file="${db_path}.backup-$(date +%Y%m%d-%H%M%S)"
    if [[ -f "$db_path" ]]; then
        log_info "备份数据库到: $backup_file"
        cp "$db_path" "$backup_file"
    fi
    
    log_info "开始导入..."
    
    # 执行导入
    if sqlite3 "$db_path" < "$sql_file"; then
        log_success "导入完成!"
        
        # 显示导入统计
        if [[ -n "$project_id" ]]; then
            local session_count
            session_count=$(sqlite3 "$db_path" "SELECT COUNT(*) FROM session WHERE project_id = '$project_id';")
            local message_count
            message_count=$(sqlite3 "$db_path" "SELECT COUNT(*) FROM message WHERE session_id IN (SELECT id FROM session WHERE project_id = '$project_id');")
            
            echo ""
            echo "导入统计:"
            echo "  Session 数量: $session_count"
            echo "  消息数量:     $message_count"
        fi
    else
        log_error "导入失败!"
        if [[ -f "$backup_file" ]]; then
            log_info "正在恢复备份..."
            cp "$backup_file" "$db_path"
            log_info "备份已恢复"
        fi
        exit 1
    fi
}

# 主函数
main() {
    local db_path="$DEFAULT_DB"
    local force="false"
    local command=""
    
    # 解析选项
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--db)
                db_path="$2"
                shift 2
                ;;
            -f|--force)
                force="true"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            export|import|list|info)
                command="$1"
                shift
                break
                ;;
            *)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 执行命令
    case "$command" in
        export)
            if [[ $# -lt 1 ]]; then
                log_error "缺少项目路径参数"
                echo "用法: $0 export <项目路径> [输出文件]"
                exit 1
            fi
            cmd_export "$db_path" "$1" "${2:-}"
            ;;
        import)
            if [[ $# -lt 1 ]]; then
                log_error "缺少 SQL 文件参数"
                echo "用法: $0 import <sql文件>"
                exit 1
            fi
            cmd_import "$db_path" "$1" "$force"
            ;;
        list)
            cmd_list "$db_path"
            ;;
        info)
            if [[ $# -lt 1 ]]; then
                log_error "缺少项目路径参数"
                echo "用法: $0 info <项目路径>"
                exit 1
            fi
            cmd_info "$db_path" "$1"
            ;;
        "")
            show_help
            exit 0
            ;;
        *)
            log_error "未知命令: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
