#!/usr/bin/env python2.7

import sys

seqLen=0
sequences=set()
print ">"+sys.argv[1]
for line in sys.stdin:
    if line.startswith(">"):
        continue
    seq=line.strip()
    if seq in sequences:
        print >>sys.stderr, "Replicate"
        continue
    sequences.add(seq)
    seqLen=len(seq)

    print ("n"*(seqLen+1))+seq

print ("n"*seqLen)