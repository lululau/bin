#!/Users/liuxiang/.rvm/rubies/ruby-2.3.2/bin/ruby

require 'yaml'

if (config = YAML.load(IO.read(File.expand_path("~/.icrt.conf")))[ARGV.first]) != nil
  puts (["cd #{config["dir"]}"] + (config["commands"] || [])) * "\n"
end
