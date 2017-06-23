#!/bin/bash

FASTQ=$1
FBIN=/opt/common/CentOS_6/fastx_toolkit/fastx_toolkit-0.0.13

OFILE=$(basename $FASTQ | sed 's/_IGO_.*//').counts
echo $OFILE

zcat $FASTQ \
    | $FBIN/fastx_trimmer -Q 33 -f 83 -l 102 \
    | $FBIN/fastq_quality_converter -Q 33 -n \
    | $FBIN/fastq_quality_filter -Q 33 -p 1 -q 20 \
    | $FBIN/fastx_collapser \
    | $FBIN/fasta_formatter -t \
    | tr '-' '\t' \
    | cut -f2,3 \
    > $OFILE
