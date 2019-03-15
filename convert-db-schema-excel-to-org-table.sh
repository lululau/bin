pbpaste | ruby -e 'x=ARGF.read; x.gsub!(/(?<!\r)\n/, " "); print x' | perl -pe 's/\t/\n\t/ if /^"/' | ruby  -ane '
if /^"/
  gsub(/"(.*)"/, "** \\1")
  puts
  print
  puts
  puts "| Name | Column | Type | Comment |"
  puts "|----- +--------+------+---------|"
  next
end

puts "| %s | %s | %s | %s |" % $F.values_at(0, 1, 2, 3)'
