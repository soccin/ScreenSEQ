# Version where exact structure of contruct is known

`makeLibraryGenome.R`

Need to have an amplicon.txt file which has the amplicon structure in it. Must have at least 3 lines where the 3 line is the TEMPLATE for the sgRNA sequence
```
AATGGACTATCATATGCTTACCGTAACTTGAAAGTAT
TTCGATTTCTTGGCTTTATATATCTTGTGGAAAGGACGAAACACC
NNNNNNNNNNNNNNNNNNNN
GTTTTAGAGCTAGAAATAGCAAGTTAAAA
TAAGGCTAGTCCGTTATCAACTTGAAAAAG
```

The library needs to be in a CSV file with the following columns

| Gene.Symbol | sgRNA.sequence |
|-------------|----------------|
|  a2m  | GGTGTCAGAAGAACACGAAG |
|  a2m  | GAGGCTGGGAGACTTTGTGA |

Note, multiple sequences per Gene.Symbol are allowed. The script will fix this. However the sequences should be unique (distinct)

Then run:

```
Rscript --no-save ./ScreenSEQ/makeLibraryGenome.R amplicon.txt LIBRARY_FILE.csv
```

And you will get

- LIBRARY_FILE__LibGenome.csv: Seq->Gene->ProbeId mapping
- LIBRARY_FILE__LibGenome.txt: sequenceId,contigSequences in tab format

Now make a genome direcotry and creat a genome FASTQ file and index it
```
mkdir genome
cat Human_GeCKOv2_Library_AB_JOIN__LibGenome.txt \
	| awk '{print ">"$1"\n"$2}' \ >genome/Human_GeCKOv2_Library_AB_JOIN__LibGenome.fa
cd genome
bwa index Human_GeCKOv2_Library_AB_JOIN__LibGenome.fa

# SEMapper complains if there is no dict file or fai file
samtools faidx Human_GeCKOv2_Library_AB_JOIN__LibGenome.fa

picard.local CreateSequenceDictionary \
R=Human_GeCKOv2_Library_AB_JOIN__LibGenome.fa \
O=Human_GeCKOv2_Library_AB_JOIN__LibGenome.dict

# Get the path to the genome in $GENOME
GENOME=$(ls $PWD/*fa)
cd ..
```

Now make a SEMapper genome file for use by SEMapper:
```
echo GENOME_FASTA=$GENOME >Human_GeCKOv2_Library_AB_JOIN
echo GENOME_BWA=$GENOME >>Human_GeCKOv2_Library_AB_JOIN
```

And then use SEMapper to map the sequences with the newly created genome file and the projects mapping file:

```
SEMapper/runPEMapperMultiDirectories.sh \
	Human_GeCKOv2_Library_AB_JOIN \
	Proj_00000_sample_mapping.txt
```

## Count BAMs with `countBAM.sh`

Use `countBAM.sh` to count the BAMs (__NOT__ the MD.bam's)

```
# Get rid of MD bams
rm out___/*MD.bam
ls out___/*bam | xargs -n 1 bsub -We 59 -o LSF/ -J COUNT ScreenSEQ/countBAM.sh 
```

## Join count files

```
Rscript --no-save ScreenSEQ/joinCounts.R Human_GeCKOv2_Library_AB_JOIN__LibGenome.csv
```

