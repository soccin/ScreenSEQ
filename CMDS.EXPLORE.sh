#!/bin/bash

FASTXBIN=./fastx_toolkit-0.0.13
GMAPPER=/ifs/work/socci/bin/gmapper-ls
FASTQ="/ifs/archive/GCL/hiseq/FASTQ/JOHNSAWYERS_0073_000000000-B8L95/Project_07665_B/Sample_Dox3_IGO_07665_B_2/Dox3_IGO_07665_B_2_S5_L001_R1_001.fastq.gz"

SGRNA_LEN=20

zcat $FASTQ \
    | $FASTXBIN/fastq_quality_filter -Q 33 -p 90 -q 30 \
    | $FASTXBIN/fastq_to_fasta -Q33 \
    | head -100000 \
    | fgrep -v ">" \
    | ./getSubSeq.py $SGRNA_LEN \
    >test.fasta

$GMAPPER --strata test.fasta human-druggable-top5_pGenome.fa >testmap.sam
cat testmap.sam \
    | fgrep NM:i:0 | fgrep ${SGRNA_LEN}M \
    | cut -f1 | sed 's/.*_//' \
    | sort | uniq -c | sort -nr | head
