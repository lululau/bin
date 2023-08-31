#!/usr/bin/env zsh

matches=$(ruby -e 'h=nil;ARGF.readlines.each {|l| l.chomp!; if l=~/^Host\s+\w/; puts h unless h.nil?; h=l.gsub(/^Host\s+/, ""); end; if l=~/^\s+Host[Nn]ame\s+\S/; puts "%-32s [ #{l.gsub(/^\s+Host.ame\s+/,"")} ]" % h; h=nil; end;}' ~/.ssh/config | FZF_DEFAULT_OPTS="--min-height 15 --reverse $FZF_DEFAULT_OPTS --preview 'echo {}' --preview-window down:3:wrap $FZF_COMPLETION_OPTS" fzf +m)

if [ -n "$matches" ]; then
  SSH_INTERACTIVE=1 ssh "${matches%% *}"
fi
