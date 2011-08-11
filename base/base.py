#!/usr/bin/env python

import sys
import math

def base_convert(num, base):
    if num == 0:
        return '0'

    # TODO : make a constant!
    tr = [ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 
           'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 
           'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 
           'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 
           'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '_', '-' ]
    
    chars = []
    while num > 0:
        chars.append(tr[num % base])
        num = int(math.floor(num/base))

    chars.reverse()
    return ''.join(chars)

if __name__ == '__main__':
    args = sys.argv[1:]
    if len(args) == 0:
        print("Usage: %s NUM [NUM...]" % sys.argv[0])
        sys.exit(1)

    # TODO: lis comprehension version?
    bases = [60,16,12,10,8,2]
    for arg in args:
        results = []
        num = int(arg, 0)

        for b in bases: 
            results.append( base_convert(num, b) )
        print( "\t".join(results) )

