#!/bin/bash

BAM=$1

sample=$(basename $BAM | sed 's/.bam//' | sed 's/s_//')

mkdir -p Counts

samtools view $BAM \
    | fgrep -w 126M \
    | perl -ne  "print if m/NM:i:[01]\s/" \
    | cut -f3 \
    | uniq -c \
    | awk '{print $2"\t"$1}' \
    >Counts/counts__${sample}



