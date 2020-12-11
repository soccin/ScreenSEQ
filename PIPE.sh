#!/bin/bash

#PARSE_SCRIPT=ScreenSEQ/parseScreenPE50__Brunello.sh
#LIBRARYFILE=ScreenSEQ/libs/Brunello_NoDatesLibFile.csv.gz

PARSE_SCRIPT=ScreenSEQ/parseScreenPE50__Brunello.sh
LIBRARYFILE=ScreenSEQ/libs/Brunello_NoDatesLibFile.csv.gz

cat *_sample_mapping.txt | cut -f4 \
    | xargs -I % find % | fgrep _R1_ \
    | xargs -n 1 bsub -o LSF/ -J COUNT_$$ -W 59 -n 15 -R "rusage[mem=2]" $PARSE_SCRIPT

bSync COUNT_$$

Rscript --no-save ScreenSEQ/joinCounts.R $LIBRARYFILE Counts


