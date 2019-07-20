#!/bin/bash
SDIR="$( cd "$( dirname "$0" )" && pwd )"

# ADAPTER_3p=GTTTTAGAGCTAGAAATAGCA
# ADAPTER_LEN=21
FDIR=$1

$SDIR/count_3pAdapter.sh GTTTTAGAGCTAGAAATAGCA 21 20 $FDIR/*_R1_*gz
