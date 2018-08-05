#!/usr/bin/env ruby

file = ARGV[0]

siblings = Dir.children(File.dirname(file)).sort

result = siblings[(siblings.index(File.basename(file))-1)%siblings.size]

system 'idea', File.dirname(file) + '/' + result + ':1'

