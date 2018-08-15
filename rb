#!/usr/bin/env ruby

def execute(_, code)
  puts _.instance_eval(&code)
rescue Errno::EPIPE
  exit
end

single_line = ARGV[0] =~ /-.*l/
active_support_required = ARGV[0] =~ /-.*A/

require 'active_support/all' if active_support_required

code = ARGV.drop(ARGV[0] =~ /-.*/ ? 1 : 0).join(' ')
code = eval("Proc.new { #{code} }")
single_line ? STDIN.each { |l| execute(l, code) } : execute(STDIN.readlines, code)
