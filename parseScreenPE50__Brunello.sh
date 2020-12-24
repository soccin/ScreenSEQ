#!/bin/bash
SDIR="$( cd "$( dirname "$0" )" && pwd )"

FBIN=/opt/common/CentOS_6/fastx_toolkit/fastx_toolkit-0.0.13

if [ "$#" -lt 1 ]; then
    echo usage: parseScreen.sh FASTQ [FASTQ2 ...]
    exit
fi

CLIPSEQ="CGGTGTTTCGTCCTTTCCACAAG"
SEQ_LEN=20
START_POS=1

FASTQS=$*

SAMPLE_ID=$(basename $1 | sed 's/_IGO_.*//' | tr '-' '_')

OFILE=${SAMPLE_ID}___COUNTS.txt
echo $OFILE, $SAMPLE_ID, $START_POS

ODIR=Counts
mkdir -p $ODIR

echo "sgRNA Counts" | tr ' ' '\t' >$ODIR/$OFILE

zcat $FASTQS ${FASTQS//_R1_/_R2_} \
    | $FBIN/fastx_reverse_complement -Q 33 \
    | $SDIR/fastq-grep $CLIPSEQ \
    | $FBIN/fastx_clipper -M 20 -c -a $CLIPSEQ -Q 33 \
    | $FBIN/fastx_reverse_complement -Q 33 \
    | $FBIN/fastx_trimmer -Q 33 -f 1 -l 20 \
    | $FBIN/fastq_quality_converter -Q 33 -n \
    | $FBIN/fastq_quality_filter -Q 33 -p 1 -q 20 \
    | $FBIN/fastx_collapser \
    | $FBIN/fasta_formatter -t \
    | tr '-' '\t' \
    | cut -f2,3 \
    | awk '{print $2,$1}' | tr ' ' '\t' \
    >> $ODIR/$OFILE

TOTAL=$(zcat $FASTQS \
    | $FBIN/fastq_to_fasta -Q 33 -n \
    | $FBIN/fasta_formatter -t \
    | wc -l
    )

echo $SAMPLE_ID $TOTAL | tr ' ' '\t' >$ODIR/${OFILE/___COUNTS.txt/___TOTAL.txt}

