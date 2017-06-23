#!/usr/bin/env python2.7

import sys

olen=int(sys.argv[1])
for sn,line in enumerate(sys.stdin):
    seq=line.strip()
    slen=len(seq)
    for i in xrange(slen-olen):
        print ">seq_%03d_%03d" %(sn+1, i+1)
        print seq[i:(i+olen)]
