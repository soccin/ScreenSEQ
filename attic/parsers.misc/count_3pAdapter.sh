#!/bin/bash
SBIN=/opt/common/CentOS_6

# ADAPTER_3p=GTTTTAGAGCTAGAAATAGCA
# ADAPTER_LEN=21

ADAPTER_3p=$1
ADAPTER_LEN=$2
SGRNA_LEN=$3
FASTQ=$4
BASE=$(basename $FASTQ | sed 's/_R1_.*gz//')

echo "sgRNA Counts" | tr ' ' '\t' >${BASE}___COUNTS.txt

zcat $FASTQ  ${FASTQ/_R1_/_R2_} \
    | $SBIN/cutadapt/cutadapt-1.9.1/bin/cutadapt \
        -a $ADAPTER_3p - -O $ADAPTER_LEN --discard-untrimmed 2> ${BASE}___ClipStats.txt \
    | $SBIN/fastx_toolkit/fastx_toolkit-0.0.13/fastx_reverse_complement -Q 33 \
    | $SBIN/fastx_toolkit/fastx_toolkit-0.0.13/fastx_trimmer -l $SGRNA_LEN -Q 33 \
    | $SBIN/fastx_toolkit/fastx_toolkit-0.0.13/fastx_reverse_complement -Q 33 \
    | $SBIN/fastx_toolkit/fastx_toolkit-0.0.13/fastq_to_fasta -Q 33 \
    | fgrep -v ">" \
    | sort \
    | uniq -c \
    | sort -rn \
    | awk '{print $2"\t"$1}' \
    >> ${BASE}___COUNTS.txt

COUNTS=$(zcat $FASTQ \
    | $SBIN/fastx_toolkit/fastx_toolkit-0.0.13/fastq_to_fasta -Q 33 -n \
    | egrep "^>" \
    | wc -l \
    | awk '{print $1}')
echo $BASE $COUNTS | tr ' ' '\t' >${BASE}___TOTAL.txt
