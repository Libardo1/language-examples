#!/usr/bin/env ruby
# A standard hexdump program. Outputs 16 bytes per line, in hex and ASCII.

=begin rdoc
Given a file handle, return an array of lines for the hexdump of that file.
=end
def hexdump(f)
  lines = []
  offset = 0
  while (buf = f.read(16)) do
    bytes = buf.unpack 'C*'
    lines << "%08X:%-48s |%-16s|" % [ 
                 offset, 
                 bytes.map { |b| " %02X" % b },
                 bytes.map { |b| b.chr =~ /[[:print:]]/ ? b.chr : '.' }.join('') 
             ]
    offset += 16
  end
  lines
end

if __FILE__ == $0
  hexdump(ARGF).each { |line| puts line }
end
