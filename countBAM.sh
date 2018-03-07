#!/bin/bash

BAM=$1

sample=$(basename $BAM | sed 's/.bam//' | sed 's/s_//')

mkdir -p Counts

correctCigar=$(samtools view $BAM \
    | cut -f6 \
    | perl -ne 'print if m/^\d+M$/' \
    |  head -10000 \
    | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')

echo "correctCigar="$correctCigar

samtools view $BAM \
    | fgrep -w $correctCigar \
    | perl -ne  "print if m/NM:i:[01]\s/" \
    | cut -f3 \
    | uniq -c \
    | awk '{print $2"\t"$1}' \
    >Counts/counts__${sample}



