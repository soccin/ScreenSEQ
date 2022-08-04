#!/bin/bash

SDIR="$( cd "$( dirname "$0" )" && pwd )"

if [ $# != "1" ]; then
    echo "usage: deliver.sh /juno/res/delivery/pi/invest"
    exit
fi

DIR=$(realpath $1)

PROJNO=$(basename $PWD)

RDIR=$DIR/$PROJNO/r_001/sgrna

mkdir -vp $RDIR

cp -v [Pp]roj_*xlsx $RDIR
cp -v [Pp]roj_*pdf $RDIR
cp -v [Pp]roj_*.csv $RDIR

echo $RDIR

echo "============================================="

# P1=$(echo $RDIR | sed 's/.*delivery.//')
# CAR=$(echo $P1 | perl -pe 's|/.*||')
# CDR=$(echo $P1 | perl -pe 's|.*?/||')
NUM_SAMPLES=$(Rscript --no-save $SDIR/countSamples.R)

# echo P1=$P1
# echo CAR=$CAR
# echo CDR=$CDR
# echo NUM_SAMPLES=$NUM_SAMPLES

cat << EOM
The results for this sgRNA library analysis are ready. You can find them on the server at:

    https://bicdelivery.mskcc.org/project/$PROJNO/other/r_001

There you will find the following files

    Proj_${PROJNO}____COUNTS.xlsx
    Proj_${PROJNO}____STATS.xlsx

These are the RAW count files for each seq and an over stat file which shows the total number of sequences and the number that had valid sgRNA sequences in them along with a PCT of how many were usable.

Then for each comparison there are two more files

    Proj__DiffAnalysis_<COMPARISON>_.pdf
    Proj__DiffAnalysis_<COMPARISON>_.xlsx

The PDF file shows several plots

1) The distribution of RAW counts (on a log2 scale) for each sample

2) A project plot that shows how the samples group in 2 dimension. It looks like PCA but it is not; it is what is called a multidimensional scaling plot.

3) Dot plot for each sequence with the log average counts normalized to counts per million (CPM) vs log FoldChange

4) A volcano plot of the gene level analysis were the individual probes for each gene are aggregated and then analysis. This plot shows the P-value for each gene vs the log Fold Change.

If you have any questions about the analysis please let me know

Nicholas Socci
Bioinformatics Core
MSKCC
soccin@mskcc.org

CHARGES:

    NG-sgRNA_Setup: Qty 1
    NG-sgRNA_Analysis: Qty $NUM_SAMPLES

EOM

