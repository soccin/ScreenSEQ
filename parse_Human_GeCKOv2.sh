#!/bin/bash
SDIR="$( cd "$( dirname "$0" )" && pwd )"

# ADAPTER_3p=GTTTTAGAGCTAGAAATAGCA
# ADAPTER_LEN=21
FIN=$1

if [[ -d $FIN ]]; then

    ARG1=$FIN/*_R1_*gz

else

    ARG1=$FIN

fi

echo $SDIR/count_3pAdapter.sh GTTTTAGAGCTAGAAATAGCA 21 20 $ARG1
