#!/bin/bash

SDIR="$( cd "$( dirname "$0" )" && pwd )"

if [ "$#" -le "2" ]; then
    echo
    echo "  "usage: MappingFile ParseScript Arg1 [Arg2] [Arg3]
    echo

    if [ "$#" -eq "2" ]; then
        echo
        $2
        echo
    fi

    exit

fi

MAPPING=$1
PARSER=$2
shift 2;

for sample in $(cat $MAPPING | cut -f2 | sort | uniq ); do

    FASTQS=$(cat $MAPPING | awk '$2=="'${sample}'"{print $4}' | xargs -I % find % -name "*.gz")
    echo
    echo bsub -o LSF.COUNT/ -J COUNT_$$ -n 5 -W 59 $PARSER $@ $FASTQS
    echo

done