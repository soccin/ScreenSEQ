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
# It also takes multiple FASTQ files

# Arg1 == ADAPTER
# Arg2...n == FASTQ's

# This one is only for samples with just _R1_ reads

ADAPTER=$1
LEN=$(($(echo $ADAPTER | wc -c) - 1))
shift 1
FASTQ=$*
BASE=$(basename $1 | sed 's/_R1.*gz//')

echo "sgRNA Counts" | tr ' ' '\t' > ${BASE}___COUNTS.txt

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
