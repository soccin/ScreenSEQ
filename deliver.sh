#!/bin/bash

if [ $# != "1" ]; then
    echo "usage: deliver.sh /ifs/res/seq/pi/invest"
    exit
fi

DIR=$1

PROJNO=$(basename $PWD)

RDIR=$DIR/$PROJNO/r_001/screen

mkdir -vp $RDIR

cp -v proj_*xlsx $RDIR
cp -v proj_*pdf $RDIR
cp -v proj_*.csv $RDIR

echo $RDIR

P1=$(echo $RDIR | sed 's/.*seq.//')
CAR=$(echo $P1 | perl -pe 's|/.*||')
CDR=$(echo $P1 | perl -pe 's|.*?/||')
NUM_SAMPLES=$(cat *_COUNTS.csv  | head -1 | tr ',' '\n' | wc -l)
NUM_SAMPLES=$(( NUM_SAMPLES - 3 ))

echo "Subject: Results for sgRNA screen $PROJNO ready"
echo
echo "The results are in:"
echo
echo "  MAC - smb://bic.mskcc.org/$CAR"
echo "  PC - \\\\bic.mskcc.org\\$CAR"
echo
echo "In folder"
echo
echo "   "/$CAR/RESULTS/$CDR
echo
echo Nicholas Socci
echo Bioinformatics Core
echo MSKCC
echo soccin@mskcc.org
echo
echo "Charges::"
echo
echo "    sgRNA_Differential_Analysis"
echo "    Samples: $NUM_SAMPLES"
echo