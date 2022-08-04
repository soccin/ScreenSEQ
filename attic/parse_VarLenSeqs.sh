#!/bin/bash
SDIR="$( cd "$( dirname "$0" )" && pwd )"

FBIN=/opt/common/CentOS_6/fastx_toolkit/fastx_toolkit-0.0.13

#
# This version is for libraries that have variable length sgRNA seqs
# (eg: LevineR/MaestreI/Proj_12333 Human)
#

# ATACTCAATTGTGGAAAGGACGAAACACCG GACCAGTCCTGCTAGGCT   GTTTAAGAGCTATGCTGGAAACAGCATAGCAAG
# ATACTCAATTGTGGAAAGGACGAAACACCG GCACAAGTTTATAAATCCAG GTTTAAGAGCTATGCTGGAAACAGCATAGCAAG
#             =================>                      <=======================
#

ADAPTER_3p=$1
ADAPTER_5p=$2
FASTQ=$3

LEN_3p=$(($(echo $ADAPTER_3p | wc -c) - 1))
LEN_5p=$(($(echo $ADAPTER_5p | wc -c) - 1))
ADAPTER_5p_RC=$(echo -e ">5p\n"$ADAPTER_5p | $FBIN/fastx_reverse_complement | fgrep -v ">")

BASE=$(basename $FASTQ | sed 's/_R1_.*gz//')

echo "sgRNA Counts" | tr ' ' '\t' >${BASE}___COUNTS.txt

zcat $FASTQ \
    | $FBIN/fastx_clipper -M $(( LEN_3p - 2 )) -c -a $ADAPTER_3p -Q 33 \
    | $FBIN/fastx_reverse_complement -Q 33 \
    | $FBIN/fastx_clipper -M $(( LEN_5p - 2 )) -c -a $ADAPTER_5p_RC -Q 33 \
    | $FBIN/fastx_reverse_complement -Q 33 \
    | $FBIN/fastq_to_fasta -Q 33 \
    | fgrep -v ">" \
    | sort \
    | uniq -c \
    | sort -rn \
    | awk '{print $2"\t"$1}' \
    >> ${BASE}___COUNTS.txt

COUNTS=$(zcat $FASTQ \
    | $FBIN/fastq_to_fasta -Q 33 -n \
    | egrep "^>" \
    | wc -l \
    | awk '{print $1}')
echo $BASE $COUNTS | tr ' ' '\t' >${BASE}___TOTAL.txt
