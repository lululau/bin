#!/usr/bin/env ruby

require "webrick"
require "webrick/httpproxy"
require "date"
require "monitor"

if ["-h", "--help", "-help"].include? ARGV[0]
    puts "useage: #{$0} <url-pattern-file> <listen port>"
    exit 0
end

lock = Monitor.new 

ansi_colors = {
    :red => 31,
    :green => 32
}

ansi_colors.each do |color, value|
    String.module_eval <<"COLOR_S_METHOD_DEF"
    def to_#{color.to_s}_s()
        "\033[#{value}m\#{self.to_s()}\033[0m"
    end
COLOR_S_METHOD_DEF

    Kernel.module_eval <<"COLOR_PUTS_METHOD_DEF"
    def #{color.to_s}_puts(str)
        if STDOUT.tty?
            puts(str.to_#{color.to_s()}_s())
        else
            puts(str)
        end
    end
COLOR_PUTS_METHOD_DEF
end

def log(str)
    "[#{DateTime.now.strftime("%F %T")}] #{str}"
end

url_patterns_file = ARGV[0]
url_patterns = []
File.open(url_patterns_file, "r") do | file |
    file.each_line do | line |
        line.chomp!
        if line =~ /^re:/            
            pattern = line.sub(/^re:\s*/, "")
            regexp = Regexp.new(pattern)
            url_patterns << regexp
        else
            url_patterns << line
        end
    end
end

if ARGV[1].to_i > 0
    port = ARGV[1].to_i
else
    port = 7000
end        

server = WEBrick::HTTPProxyServer.new(
    :Port => port,
    :AccessLog => [],
    :ProxyContentHandler => Proc.new do |req, res|
        req_line = req.request_line
        url = req_line.sub(/^\w+\s/, "").sub("\sHTTP/1\.[01]$", "")
        url_patterns.each do |pattern|            
            if pattern.instance_of? String
                if not url.include? pattern
                    next 
                end
            elsif pattern.instance_of? Regexp
                if not pattern.match(url)
                    next
                end
            end
            lock.synchronize do 
                puts log req_line
                red_puts log  "    Request Headers: "
                req.each do | header_name, header_values |
                    header_values.each do |value|
                        red_puts log "        #{header_name}: #{value}"
                    end
                end
                green_puts log "    Response Status & Headers: "
                green_puts log "        #{res.status_line.chomp}"
                res.each do | header_name, header_values |
                    header_values.each do |value|
                        green_puts log "        #{header_name}: #{value}"
                    end
                end
                STDOUT.flush
            end
            break
        end
    end
)

trap "INT" do 
    STDOUT.flush
    server.shutdown 
end
server.start