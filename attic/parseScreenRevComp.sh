#!/bin/bash

FBIN=/opt/common/CentOS_6/fastx_toolkit/fastx_toolkit-0.0.13

if [ "$#" != "3" ]; then
    echo usage: parseScreen.sh START_POS SEQ_LEN FASTQ
    exit
fi

START_POS=$1
SEQ_LEN=$2
END_POS=$((START_POS+SEQ_LEN-1))
FASTQ=$3

OFILE=$(basename $FASTQ | sed 's/_IGO_.*//').counts
echo $OFILE, $START_POS, $END_POS

ODIR=LibCounts
mkdir -p $ODIR

zcat $FASTQ \
    | $FBIN/fastx_trimmer -Q 33 -f $START_POS -l $END_POS \
    | $FBIN/fastq_quality_converter -Q 33 -n \
    | $FBIN/fastq_quality_filter -Q 33 -p 1 -q 20 \
    | $FBIN/fastx_reverse_complement \
    | $FBIN/fastx_collapser \
    | $FBIN/fasta_formatter -t \
    | tr '-' '\t' \
    | cut -f2,3 \
    > $ODIR/$OFILE
