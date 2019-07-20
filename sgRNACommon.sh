#!/bin/bash

BINDIR=/opt/common/CentOS_6/fastx_toolkit/fastx_toolkit-0.0.13
FASTQ=$1
BASE=$(basename $FASTQ | sed 's/.fastq.gz//')
zcat $FASTQ \
    | $BINDIR/fastx_clipper -Q33 -a GTTTTAGAGCTAGAAATAGCAAGTT -M 10 -c \
    | $BINDIR/fastx_reverse_complement -Q 33 \
    | $BINDIR/fastx_trimmer -f 1 -l 20 -Q 33 \
    | $BINDIR/fastx_reverse_complement -Q 33 \
    | $BINDIR/fastq_quality_converter -Q 33 -n \
    | $BINDIR/fastq_quality_filter -Q33 -p 1 -q 19 \
    | $BINDIR/fastx_collapser \
    | $BINDIR/fasta_formatter -t \
    | tr '-' '\t' \
    | awk '{print $3,$2}' \
    | tr ' ' '\t' \
    | sort -k2,2nr \
    > ${BASE}_counts.txt

COUNTS=$(zcat $FASTQ | $BINDIR/fastq_to_fasta -Q 33 -n | egrep "^>" | wc -l)
echo $BASE $COUNTS | tr ' ' '\t' >${BASE}_total.txt
