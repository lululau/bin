#!/usr/bin/env ruby

require 'webrick'
require 'webrick/httpproxy'

proxy_server = WEBrick::HTTPProxyServer.new(:Port => 8080,
                                           :AccessLog => [],
                                           )

trap('INT') { proxy_server.shutdown }
proxy_server.start

