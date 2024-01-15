#!/usr/bin/env ruby

if ARGV.length == 0
  if STDIN.tty?
    input = `/usr/bin/pbpaste`
  else
    input = STDIN.read
  end

  if STDOUT.tty?
    output = :PBCOPY
  else
    output = STDOUT
  end
else
  input = File.read(ARGV[0])
  output = File.open(ARGV[1], 'w')
end

IO.popen("pandoc --filter=$HOME/.config/pandoc-org-filter.py --columns=120 -f markdown -t org", "r+") do |io|
  io.write(input)
  io.close_write
  if output == :PBCOPY
    out = io.read
    IO.popen("/usr/bin/pbcopy", "w") { |f| f.write(out) }
    puts out
    puts "\nCopied to clipboard."
  else
    output.write(io.read)
  end
end
