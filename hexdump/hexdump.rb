#!/usr/bin/env ruby

offset = 0
while (buf = ARGF.read(16)) do
       bytes = buf.unpack 'C*'
       puts "%08X :%-48s |%-16s|" % [ offset, 
              bytes.map{ |b| " %02X" % b },
              bytes.map{ |b| b.chr =~ /[[:print:]]/ ? b.chr : '.' }.join('') ]
       offset += 16
end
