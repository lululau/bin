#!/bin/bash

cat | ruby -e 'x=ARGF.read; x.gsub!(/(?<!\r)\n/, " "); print x' | perl -pe 's/\t/\n\t/ if /^"/' | ruby -F$'\t'  -ane '
if /^"/
  gsub(/"(.*)"/, "** \\1")
  puts
  print
  puts
  puts "| 废弃 | 中文名称 | 字段名 | 类型 | 主键 | 允许为空 | 是否唯一 | 默认值 | 备注 |"
  puts "|-----|----- +--------+------+-----+------+--------+-------+----|"
  next
end

puts "|  | %s | =%s= | =%s= | %s | %s | %s | %s | %s |" % $F.values_at(1, 2, 3, 4, 5, 6, 7, 8).map{|e|(e||"").chomp}'


