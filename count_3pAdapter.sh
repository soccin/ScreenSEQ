#!/bin/bash
SBIN=/opt/common/CentOS_6

ADAPTER_3p=GTTTTAGAGCTAGAAATAGCA
ADAPTER_LEN=21

FASTQ=$1
BASE=$(basename $FASTQ | sed 's/.fastq.gz//')

echo "sgRNA Counts" | tr ' ' '\t' >${BASE}___COUNTS.txt

zcat $FASTQ  ${FASTQ/_R1_/_R2_} \
    | $SBIN/cutadapt/cutadapt-1.9.1/bin/cutadapt -a $ADAPTER_3p - -O $ADAPTER_LEN --discard-untrimmed 2> LOG \
    | $SBIN/fastx_toolkit/fastx_toolkit-0.0.13/fastx_reverse_complement -Q 33 \
    | $SBIN/fastx_toolkit/fastx_toolkit-0.0.13/fastx_trimmer -l 20 -Q 33 \
    | $SBIN/fastx_toolkit/fastx_toolkit-0.0.13/fastx_reverse_complement -Q 33 \
    | $SBIN/fastx_toolkit/fastx_toolkit-0.0.13/fastq_to_fasta -Q 33 \
    | fgrep -v ">" \
    | sort \
    | uniq -c \
    | sort -rn \
    | awk '{print $2"\t"$1}' \
    >> ${BASE}___COUNTS.txt
