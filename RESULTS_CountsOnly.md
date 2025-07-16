# ScreenSeq Pipeline

## Version:

- feature/simpleScripts (2020-12-23)

## Description of results:

### Counts and QC-Stats

- `<ProjectNo>____STATS.xlsx` --- Overall QC stats for run; table columns are:

|Column | Description |
|-------|-------------|
|Sample | SampleId |
|Total  | Total number of reads |
|Num.Processed | Number of reads that had a valid sgRNA sequence |
|Num.Library | Number of reads found in sgRNA library |
|PCT.Useable | Num.Library / Total |

`PCT.Useable` gives a measure of the quality of the library. If it is low or if there is one or more samples whose values are much lower than the others this may indicate some QC issues.

- `<ProjectNo>____COUNTS.xlsx` --- Raw count file.

Raw (unnormalized) counts for each sample

|Column | Description |
|-------|-------------|
|sgRNA  | Sequence of sgRNA |
|Gene   | Gene targeted |
|ProbeID| Unique Probe Id |
|LibName| Library Name |
|Samp1  | Sample 1 counts |
|...    | ... |
|SampN  | Sample N counts |

