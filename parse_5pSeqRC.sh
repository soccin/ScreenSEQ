#!/bin/bash

FBIN=/opt/common/CentOS_6/fastx_toolkit/fastx_toolkit-0.0.13

#
# This version is for libraries that have fix length sgRNA's that are
# at the start of the sequence and the lib sequence is the reverse
# complement of the sequence read
# (eg: KentsisA/TakaoS/Proj_12353)
#

# GCACAAGTTTATAAATCCAG TACATCTGTGGCTTCACTAATCTCGTATGCCGTCTTCTGC
# <====  sgSeq   ====> <====== Adapter =================
#          |
#          v
# CTGGATTTATAAACTTGTGC
#
#
# It also takes multiple FASTQ files OR a folder with FASTQ's in it
# Only the R1 read is used.

# Arg1 == ADAPTER
# Arg2...n == FASTQ's

# This one is only for samples with just _R1_ reads

if [ "$#" -lt 2 ]; then
    echo
    echo "  usage: parse_5pSeqRC.sh ADAPTER_SEQ (FASTQ_R1|FASTQ_DIR) [FASTQ_R1 FASTQ_R1 ...]"
    echo
    exit
fi

ADAPTER=$1
LEN=$(($(echo $ADAPTER | wc -c) - 1))
shift 1

FASTQARG1=$(realpath $1)

if [ -d "$FASTQARG1" ]; then
    FASTQ=$(ls $FASTQARG1/*_R1_*.fastq.gz)
    F1=$(ls $FASTQARG1/*_R1_*.fastq.gz | head -1)
    BASE=$(basename $F1 | sed 's/_R1.*gz//')
else
    FASTQ=$*
    BASE=$(basename $1 | sed 's/_R1.*gz//')
fi

echo "sgRNA Counts" | tr ' ' '\t' > ${BASE}___COUNTS.txt

echo
echo "FASTQs"
echo $FASTQ | tr ' ' '\n'
echo

zcat $FASTQ \
    | $FBIN/fastx_clipper -Q 33 -a $ADAPTER -M $(( LEN - 2 )) -c \
    | $FBIN/fastx_reverse_complement -Q 33 \
    | $FBIN/fastq_to_fasta -Q 33 \
    | fgrep -v ">" \
    | sort -S 1g \
    | uniq -c \
    | awk '{print $2"\t"$1}' \
    >> ${BASE}___COUNTS.txt

COUNTS=$(zcat $FASTQ \
    | $FBIN/fastq_to_fasta -Q 33 -n \
    | egrep "^>" \
    | wc -l \
    | awk '{print $1}')
echo $BASE $COUNTS | tr ' ' '\t' >${BASE}___TOTAL.txt
