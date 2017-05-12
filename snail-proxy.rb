#!/usr/bin/env ruby

require "webrick"
require "webrick/httpproxy"

s = WEBrick::HTTPProxyServer.new(
    :Port => 8888,
    :AccessLog => [],
    :ProxyContentHandler => Proc.new do |req, res|
        sleep ARGV[0].to_i
    end
    )

trap "INT" do s.shutdown end
s.start    