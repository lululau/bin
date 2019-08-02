#!/usr/bin/env SSH_INTERACTIVE=1 ruby

# Init
require 'rdialog'
require 'yaml'
require 'yaml_config'

trap(:INT) do
  system 'clear'
  exit(1)
end

if system('dialog &> /dev/null') != true
	raise "Cannot call dialog: Not installed?"
end
dialog = RDialog.new
config = YamlConfig.new("#{ENV['HOME']}/.config/ssh-dialog.yml")

# Default username
if config.get(:defaults)['username'].nil?
    defaultUser = nil
else
    defaultUser = config.get(:defaults)['username']
end

# Groups dialog
groups = Array.new
config.get(:groups).each do |group|
    groups.push([group[0]])
end
group = dialog.menu("Select a group:", groups)
if group == false
	# raise "No group selected"
  system 'clear'
  exit(1)
end

# Hosts dialog
hosts = Array.new
config.get(:groups)[group]['hosts'].each do |host|
    hosts.push(["#{host[0]}", "#{host[1]['hostname']}"])
end
host = dialog.menu("Select host:", hosts)
if host == false
	# raise "No host selected"
  system 'clear'
  exit(1)
end
hostname = config.get(:groups)[group]['hosts'][host]['hostname']

# Key selection, host overrides group key:
key = false
if not config.get(:groups)[group]['key'].nil?
	key = config.get(:groups)[group]['key']
end
if not config.get(:groups)[group]['hosts'][host]['key'].nil?
	key = config.get(:groups)[group]['hosts'][host]['key']
end

# Final username
if config.get(:groups)[group]['hosts'][host]['username'].nil?
    user = defaultUser
else
    user = config.get(:groups)[group]['hosts'][host]['username']
end

# Port
if config.get(:groups)[group]['hosts'][host]['port'].nil?
    port = nil
else
    port = config.get(:groups)[group]['hosts'][host]['port']
end

# SSH
system('clear')
puts "Connectig to #{hostname} with user #{user}..."

if cmd = config.get(:groups)[group]['hosts'][host]['command']
  fork do
    sleep 1
    system "osascript", "-e", "tell app \"iTerm\" to tell current session of current window to write text \"%s\"" % cmd
  end
end

if key == false
	exec(format("ssh %s %s#{hostname}", (port ? "-p#{port}" : ''), (user ? "#{user}@" : '')))
	#puts "ssh -p#{port} #{user}@#{hostname}"
else
	exec(format("ssh -p#{port} -i #{key} %s@#{hostname}", (port ? "-p#{port}" : ''), (user ? "#{user}@" : '')))
	#puts "ssh -p#{port} -i #{key} #{user}@#{hostname}"
end


