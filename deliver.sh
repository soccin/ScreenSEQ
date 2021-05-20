#!/bin/bash

SDIR="$( cd "$( dirname "$0" )" && pwd )"

if [ $# != "1" ]; then
    echo "usage: deliver.sh /ifs/res/seq/pi/invest"
    exit
fi

DIR=$1
DIR=$(echo $DIR | perl -pe 's|/$||')

PROJNO=$(basename $PWD)

RDIR=$DIR/$PROJNO/r_001/screen

mkdir -vp $RDIR

cp -v [Pp]roj_*xlsx $RDIR
cp -v [Pp]roj_*pdf $RDIR
cp -v [Pp]roj_*.csv $RDIR

echo $RDIR

P1=$(echo $RDIR | sed 's/.*delivery.//')
CAR=$(echo $P1 | perl -pe 's|/.*||')
CDR=$(echo $P1 | perl -pe 's|.*?/||')
NUM_SAMPLES=$(Rscript --no-save $SDIR/countSamples.R)

echo "Subject: Results for sgRNA screen $PROJNO ready"
echo
echo "The results are in:"
echo
echo "  MAC - smb://beta.mskcc.org/$CAR"
echo "  PC - \\\\beta.mskcc.org\\$CAR"
echo
echo "In folder"
echo
echo "   "/$CAR/DELIVERY/$CDR
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