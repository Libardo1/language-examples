#!/usr/bin/env python
# A standard hexdump program. Outputs 16 bytes per line, in hex and ASCII.

import struct
import sys

'''
Return the ASCII value of a byte if it is printable, else return '.'.
'''
def byte_to_ascii(b):
    if (b < 0x20 or b > 0x7E):
        return '.'
    return chr(b)

'''
Given a file handle, return an array of lines for the hexdump of that file.
'''
def hexdump(f):
    lines = []
    offset = 0

    while True:
        buf = f.read(16)
        if buf == '':
            break

        bytes = struct.unpack('16B', buf)
        hex = ' '.join( ["%02X" % b for b in bytes] )
        ascii = ''.join( [byte_to_ascii(b) for b in bytes] )

        lines.append("%08X:%-48s |%-16s|" % (offset, hex, ascii))
        offset += 16

    return lines

if __name__ == '__main__':
    lines = []
    if len(sys.argv[1:]) > 0:
        for file in sys.argv[1:]:
            f = open(file, 'rb')
            lines.extend( hexdump(f) )
            f.close
    else:
        lines = hexdump(sys.stdin)

    for line in lines:
        print line
