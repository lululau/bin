#!/usr/bin/env zsh

depth=${1:-2}

[ $# -gt 0 ] && shift

ruby -ne "
BEGIN {
  \$counters = Array.new($depth, 0)
}

unless /^#/
  print; next
end

mark = \$_.scan(/^#+/)[0]

level = mark.size - 1

unless level < $depth
  print; next
end

\$counters[level] += 1

\$counters[level+1] = 0 if level < \$counters.size - 1

sub(/^#+ /) {|m| m + (level + 1).times.map { |i| \$counters[i].to_s }.join('.') + ' ' }

print

" $1
