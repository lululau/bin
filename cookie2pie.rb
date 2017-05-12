#!/usr/bin/env ruby

require 'json'

pie = {
    "__meta__" => {
        "about" => "HTTPie session file", 
        "help" => "https://github.com/jkbr/httpie#sessions", 
        "httpie" => "0.8.0"
    }, 
    "auth" => {
        "password" => nil, 
        "type" => nil, 
        "username" => nil
    }, 
    "cookies" => {}, 
    "headers" => {}
}

if STDIN.isatty
  file_content = %x{pbpaste}.split("\n")
else
  file_content = STDIN.readlines
end

pie['cookies'] = file_content.reduce({}) do |h, line|
  unless line =~ /^\s*#/ 
    _, _, path, secure, expires, name, value = line.split("\t")
    if name
      h[name] = {
        "expires" => expires.to_i,
        "path" => path,
        "secure" => secure == "TRUE",
        "value" => value
      }
    end
  end
  h
end

puts JSON.pretty_generate(pie)
