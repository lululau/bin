#!/usr/bin/env zsh

# 脚本名称：c
# 功能：捕获当前终端内容并在 Emacs 编辑器中打开
#
# 支持的终端环境：
# - Tmux：使用 tmux capture-pane 命令捕获当前面板内容
# - macOS iTerm：使用 AppleScript 获取当前会话内容
# - 其他终端：默认处理
#
# 工作流程：
# 1. 检测终端环境并选择合适的捕获命令
# 2. 创建临时文件存储捕获的内容
# 3. 使用 Perl 处理文本格式
# 4. 在 Emacs 中打开文件（跳转到文件末尾）
# 5. 清理临时文件
#
# 使用场景：
# - 需要编辑终端输出内容
# - 在 Emacs 中查看命令历史或输出
# - 从终端快速复制大段文本到编辑器

if [ -n "$TMUX" ]; then
  capture_cmd='tmux capture-pane -pS -'
elif [ $(uname) = Darwin ]; then
  local contents=$(osascript -e "tell app \"iTerm\" to get contents of current session of current tab of current window")
  capture_cmd='echo "$contents"'
else
    capture_cmd='echo'
fi

tmpfile=$(mktemp)
basename=$(basename "$tmpfile")
eval "$capture_cmd" | perl -00 -pe 1 > "$tmpfile"
if [ "$(uname)" = Darwin ]; then
  # emacsclient -t -s term -e "(progn (find-file \"$tmpfile\") (linum-mode) (end-of-buffer))"
  # emacsclient -n -s term -e "(kill-buffer \"$basename\")"
  emacsclient -q -e "(progn (find-file \"$tmpfile\")  (end-of-buffer))"
  osascript -e "tell app \"Emacs\" to activate"
else
   emacsclient -q -e "(progn (find-file \"$tmpfile\")  (end-of-buffer))"
fi

rm "$tmpfile"
