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

