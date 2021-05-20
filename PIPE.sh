#!/bin/bash

#PARSE_SCRIPT=ScreenSEQ/parseScreenPE50__Brunello.sh
#LIBRARYFILE=ScreenSEQ/libs/Brunello_NoDatesLibFile.csv.gz

PARSE_SCRIPT=ScreenSEQ/parseScreenPE50__Brunello.sh
LIBRARYFILE=ScreenSEQ/libs/Brunello_NoDatesLibFile.csv.gz

samples=$(cat *_sample_mapping.txt | cut -f2 | sort | uniq)

for si in $samples; do
    cat *_sample_mapping.txt | fgrep $si | cut -f4 \
        | xargs -I % find % | fgrep _R1_ \
        | xargs bsub -o LSF/ -J COUNT_$$ -W 359 -n 15 -R "rusage[mem=2]" $PARSE_SCRIPT
done

bSync COUNT_$$

Rscript --no-save ScreenSEQ/joinCounts.R $LIBRARYFILE Counts


