# ScreenSeq Pipeline - Results

## Output Files and Results

The pipeline generates three main types of output files. The quality control statistics file (`<ProjectNo>____STATS.xlsx`) contains essential metrics for each sample including total read counts, processed reads with valid sgRNA sequences, library-matched reads, and the critical PCT.Useable percentage. This percentage serves as the primary quality indicator, with values above 80% indicating excellent library quality, while values below 50% suggest potential sequencing or library preparation issues that warrant investigation.

Raw count data is provided in `<ProjectNo>____COUNTS.xlsx`, containing the unnormalized abundance of each sgRNA across all samples. Each row represents a unique sgRNA with its target gene, probe identifier, library name, and individual sample counts. This file serves as the foundation for all downstream statistical analyses.

For differential analysis, the pipeline produces both visual and tabular results. The PDF report (`<ProjectNo>_DiffAnalysis_<SetName>_.pdf`) contains four diagnostic plots: a boxplot showing data distribution across samples, an MDS plot for sample clustering visualization, a scatter plot of log intensity versus fold change, and a volcano plot for gene-level significance analysis. The accompanying Excel file (`<ProjectNo>_DiffAnalysis_<SetName>_.xlsx`) contains two data sheets with detailed statistical results at both probe and gene levels.
