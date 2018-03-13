#!/usr/bin/env ruby

require 'json'

# Substitute prefix dirs with local baton project root dir or pwd, so that if
# you use this script in iTerm2, you could command-click the full pathname to
# open the file in your favorite editor.
LOCAL_RAILS_PROJECT_ROOT = ENV['LOCAL_RAILS_PROJECT_ROOT'] || Dir.pwd

GEM_DIR = `rvm gemdir`.chomp
GEM_BIN_DIR = GEM_DIR.sub(/gems/, 'rubies')

# Read from STDIN if it's attached to a PIPE, or else use the pbpaste system
# command to read from system clipboard(OS X only).
raw_err_text = STDIN.isatty ? `pbpaste` : STDIN.read

# Extract Ruby exeception backtrace text
backtraces_text = raw_err_text[/\[[^\[\]]*\].*$/m].gsub(/\n/, '')

JSON.parse(backtraces_text).each do |trace|
  if trace =~ %r<^/home/[^/]+/(\.rvm/.*)>
    # Replace with your own home dir.
    puts "#{Dir.home}/#{$1}"
  elsif trace =~ %r<.*/releases/\d+/vendor/.*/(gems/.*)>
    puts "#{GEM_DIR}/#{$1}"
  elsif trace =~ %r<.*/releases/\d+/vendor/.*/(bin/.*)>
    puts "#{GEM_BIN_DIR}/#{$1}"
  elsif trace =~ %r<.*/releases/\d+/(.*)>
    # Highlight paths under baton code base.
    puts STDOUT.isatty ? "\033[33m#{LOCAL_RAILS_PROJECT_ROOT}/#{$1}\033[0m" : "#{LOCAL_RAILS_PROJECT_ROOT}/#{$1}"
  else
    puts trace
  end
end
