#!/bin/bash

./ScreenSEQ/Parser/scanner seq /igo/delivery/FASTQ/RUTH_0436_BH3N2HDSXF/Project_17105/Sample_SC1top5_IGO_17105_3/SC1top5_IGO_17105_3_S157_L004_R1_001.fastq.gz 
./ScreenSEQ/Parser/scanner --flanking-length 16 seq /igo/delivery/FASTQ/FAUCI2_0125_A2372JMLT3/Project_18147/Sample_RSL3-2-2_IGO_18147_26/RSL3-2-2_IGO_18147_26_S100_L001_R1_001.fastq.gz

./runProject.sh meta/Proj_17105_sample_mapping.txt ScreenSEQ/Parser/parser_5p3p GTGGAAAGGACGAAACACCG GTTTTAGAGCTAGAAATAGC
./ScreenSEQ/runProject.sh ../meta/Proj_18147_sample_mapping.txt ScreenSEQ/Parser/parser_5p3p AAAGGACGAAACACCG GTTTTAGAGCTAGAAA

mkdir Counts
mv *___* Counts/

Rscript ScreenSEQ/bin/joinCounts.R ScreenSEQ/libraries/Brunello_NoDatesLibFile.csv.gz Counts/

