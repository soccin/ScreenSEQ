# ScreenSEQ
Code for processing sh/sg-RNA or CRISPR screens. 

Currently this code only works when there is no stagger. 

## Find position of seq

If the position of the seq in the read is know then skip to next section. If not then follow these steps to try to figure out 

1. Is the position of the seq is constant
2. What it is
3. What the strand is

First convert the library to fasta format and pipe this to `mkPseudoGenome.py` to get a genome of library sequences. No code for this yet since libraries do not seem to have a standard format. An example:
```{bash}
mkdir Construct
cat human-druggable-top5.csv \
	| fgrep -v Gene.Symbol \
	| awk -F',' '{print ">"$1"."++s"\n"$2}' \
	| ./mkPseudoGenome.py human-druggable-top5 \
	>Construct/human-druggable-top5.fa
```

_N.B._ `mkPseudoGenome.py` will output the length of the screen library sequences. If they are not all the same this code will not work as is.

Now get one FASTQ for the run and do:
```{bash}
./findScreenPos.sh \
	Construct/human-druggable-top5.fa \
	$LIB_SEQ_LEN \
	/path/to/fastq/file.fastq.gz
```

If there is a well defined position this should find it. Use this in the next step

## Count library sequences

Once you know the `START_POS` and `SEQ_LEN` of the library you can count the number of screen sequences with `parseScreen.sh`:
```{bash}
$ ./parseScreen.sh 
usage: parseScreen.sh START_POS SEQ_LEN FASTQ
$ 
```

Use the following to loop over all FASTQ files in a mapping file and submit to cluster.
```{bash}
cat Proj_*_sample_mapping.txt \
	| cut -f4 \
	| xargs -n 1 -I % find % -name '*_R1_*.fastq.gz' \
	| xargs -n 1 bsub -o LSF/ -J PARSE -We 59 \
		./parseScreen.sh $START_POS $SEQ_LEN 
```

Note this only processes the R1 reads and will only work correct if there is one FASTQ block per sample.

When finished the count files will be in the `LibCounts` directory.

## Join Count File for analysis

Use the R script `loadData.R` to parse the count files, join them with the library sequences and make a library count table. Again due to the different formats for the library files you need to customize the reading of it before running the script. 

When run you will get:

* `$PROJNO__CountTable.csv`
* `$PROJNO_COUNTS.rda`
* `$PROJNO_STATS.xlsx`

Check `$PROJNO_STATS.xlsx` for %-counted and if differential analysis is to be done add a `Group` column with group names.

## Differential Analysis

If the `Group` column has been added to the STATS.xlsx file then:
```
Rscript --no-save diffAnalysis.R
```
should run the analysis. Check the plots to make sure the normalization worked. 



