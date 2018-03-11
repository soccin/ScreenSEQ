#!/bin/bash

BAM=$1

sample=$(basename $BAM | sed 's/.bam//' | sed 's/s_//')

mkdir -p Counts


cigarTable=$(
    samtools view $BAM \
    | fgrep NM:i:0 \
    | cut -f2,6 \
    | head -10000 \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -2 )

echo "CigarTable ="$cigarTable
correctCigar=$(echo $cigarTable | awk '{print $3"|"$6}')
echo $correctCigar

samtools view $BAM \
    | egrep -w "$correctCigar" \
    | perl -ne  "print if m/NM:i:[01]\s/" \
    | cut -f3 \
    | uniq -c \
    | awk '{print $2"\t"$1}' \
    >Counts/counts__${sample}



