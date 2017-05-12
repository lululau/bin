#!/usr/bin/env ruby

require 'webrick'
require 'pry-byebug'

server = WEBrick::HTTPServer.new(Port: ARGV[0] || 8080)

server.mount_proc(ARGV[1] || '/') do |req, res|
  raw_header = req.raw_header
  request_line = req.request_line
  body = req.body
  cookies = req.cookies
  socket = req.instance_variable_get('@socket')
  require 'pry'; binding.pry;
end

%w[INT TERM].each { |signal| trap(signal) { server.shutdown } }

server.start

