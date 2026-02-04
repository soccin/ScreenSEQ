# ScreenSEQ

**Version: 2.1.0** | **Release: 2025-08-31**

A Python3-based pipeline for analyzing sgRNA (single guide RNA) screen sequencing data from CRISPR screens.

## Overview

ScreenSEQ processes FASTQ files from CRISPR screening experiments to:
- Parse and extract sgRNA sequences from raw sequencing reads
- Count sgRNA occurrences across samples  
- Perform differential expression analysis to identify significant hits
- Generate comprehensive reports and visualizations

## Features

- **Flexible Parsing**: Multiple parser configurations for different adapter setups
- **Parallel Processing**: LSF job scheduler integration for high-throughput analysis
- **Statistical Analysis**: EdgeR-based differential expression analysis
- **Quality Control**: Comprehensive statistics and diagnostic plots
- **Automated Reporting**: Ready-to-deliver results with summary reports

## Quick Start

### Basic Brunello Screen Analysis

```bash
# Run the basic Brunello pipeline
./PIPE_Brunello.sh
```

### Custom Analysis

```bash
# Run with custom mapping and parser
./runProject.sh mapping_file.txt Parser/parser_5p3p [ARGS]

# Join counts
mkdir Counts
mv *___* Counts/

# R1 Only
Rscript ScreenSEQ/bin/joinCounts.R ScreenSEQ/libraries/Brunello_NoDatesLibFile.csv.gz Counts/

# R1R2
Rscript ScreenSEQ/bin/joinCountsR1R2.R ScreenSEQ/libraries/Brunello_NoDatesLibFile.csv.gz Counts/

# Perform differential analysis
Rscript diffAnalysis.R

# Generate delivery package
./bin/deliver.sh /path/to/delivery/directory
```

## Project Structure

```
├── Parser/           # FASTQ parsing tools and utilities
│   ├── parser_*      # Different parser configurations
│   └── tools/        # Core FASTQ processing utilities
├── bin/              # Analysis and utility scripts
├── libraries/        # Reference sgRNA libraries (Brunello, GeCKOv2)
├── docs/             # Documentation and results templates
└── attic/            # Legacy scripts and utilities
```

## Requirements

### R Dependencies
- tidyverse
- magrittr  
- openxlsx
- readxl
- edgeR

### System Requirements
- Python 3.x
- R with required packages
- LSF job scheduler (for parallel processing)
- Access to reference libraries

## Input Data

- **FASTQ files**: Gzipped sequencing data
- **Mapping file**: Sample metadata and file paths
- **Library file**: Reference sgRNA sequences (CSV format)

## Output Files

- `Proj_*____COUNTS.xlsx` - Raw sgRNA counts per sample
- `Proj_*____STATS.xlsx` - Quality control statistics  
- `Proj__DiffAnalysis_*.pdf` - Analysis plots and visualizations
- `Proj__DiffAnalysis_*.xlsx` - Differential expression results

## Alternative Implementations

For **MAGeCK**-based analysis, see [ScreenSEQ_MAGeCK](https://github.com/soccin/ScreenSEQ_MAGeCK)

## Documentation

See `CLAUDE.md` for detailed development guidelines and architecture documentation.

## Support

For questions about analysis or technical issues, contact the Bioinformatics Core.
