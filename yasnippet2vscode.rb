#!/usr/bin/env ruby

require 'active_support/all'

def convert_yasnippet_to_vscode(yasnippet)
  lines = yasnippet.lines()
  prefix = lines.grep(/^# *key *: */).first.try { |line| line.gsub(/^# *key *: */, '').strip }
  return unless prefix

  description = lines.grep(/^# *name *: */).first.try { |line| line.gsub(/^# *name *: */, '').strip }
  return unless description

  body = lines.grep(/^[^#]/).map(&:chomp);
  return unless body.present?

  snippet = {}
  snippet['prefix'] = prefix
  snippet['body'] = body
  snippet['description'] = description
  snippet
end

result = ARGV.each_with_object({}) do |yasnippet_file, hash|
  vscode_snippet = convert_yasnippet_to_vscode(File.read(yasnippet_file))
  next unless vscode_snippet

  hash[yasnippet_file] = vscode_snippet
end

puts JSON.pretty_generate(result)
