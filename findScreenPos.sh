#!/bin/bash

FASTXBIN=/opt/common/CentOS_6/fastx_toolkit/fastx_toolkit-0.0.13
GMAPPER=/ifs/work/socci/bin/gmapper-ls

USAGE="usage: findScreenPos.sh SCREEN_GENOME SGRNA_LEN FASTQ"
if [ "$#" != "3" ]; then
    echo $USAGE
    exit
fi

GENOME=$1
SGRNA_LEN=$2
FASTQ=$3

zcat $FASTQ \
    | $FASTXBIN/fastq_quality_filter -Q 33 -p 90 -q 30 \
    | $FASTXBIN/fastq_to_fasta -Q33 \
    | head -10000 \
    | fgrep -v ">" \
    | ./getSubSeq.py $SGRNA_LEN \
    >test.fasta

if [ "$?" != "0" ]; then
    echo
    echo "FATAL ERROR"
    echo
    echo $USAGE
    echo
    exit
fi


$GMAPPER --strata test.fasta $GENOME >testmap.sam

echo
echo
echo

cat testmap.sam \
    | fgrep NM:i:0 | fgrep ${SGRNA_LEN}M \
    | cut -f1 | sed 's/.*_//' \
    | sort | uniq -c | sort -nr \
    | awk '{printf("%d\t%d\n",$2,$1)}' \
    | tee posStats.txt | head
