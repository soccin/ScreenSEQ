# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ScreenSEQ is a Python3-based pipeline for analyzing sgRNA (single guide RNA) screen sequencing data. It parses FASTQ files, counts sgRNA occurrences, and performs differential expression analysis to identify significant hits in CRISPR screens.

## Key Commands

### Running Analysis
- `./runProject.sh MAPPING_FILE PARSER_SCRIPT [ARGS]` - Main project runner that submits LSF jobs for each sample
- `Rscript diffAnalysis.R` - Performs differential analysis on count data (requires COUNTS.xlsx and STATS.xlsx files)
- `Rscript plotStatsDraft.R` - Generates diagnostic plots for quality control

### Delivery
- `./bin/deliver.sh /path/to/delivery/directory` - Copies results to delivery location and generates summary email

### Documentation Generation
- `pandoc RESULTS.md --variable geometry:margin=0.75in --variable fontsize=11pt -o RESULTS.pdf` - Converts results documentation to PDF

## Architecture

### Core Components

**Parser System** (`Parser/` directory):
- Multiple parser scripts handle different adapter/sequence configurations:
  - `parser_3pAdapter` - 3' adapter parsing
  - `parser_5pAdapter` - 5' adapter parsing  
  - `parser_5p3p` - Dual-end adapter parsing
  - `parser_HomoPoly` - Homopolymer sequence handling
- `tools/FASTQ.py` - Core FASTQ file reading utilities with gzip support
- Uses LSF job scheduler for parallel processing (`bsub` commands)

**Analysis Pipeline**:
1. FASTQ parsing and sgRNA counting (Python parsers)
2. Count aggregation (R scripts in `bin/`)
3. Differential analysis using edgeR (`diffAnalysis.R`)
4. Results delivery and reporting (`bin/deliver.sh`)

**Key Libraries**:
- `libraries/` contains reference sgRNA libraries (Brunello, GeCKOv2)
- Compressed CSV format for genomic annotations

### R Dependencies
- tidyverse, magrittr, openxlsx, readxl, edgeR
- Assumes specific file naming: `Proj_*____COUNTS.xlsx`, `Proj_*____STATS.xlsx`

### Data Flow
1. Input: FASTQ files + mapping file specifying sample relationships
2. Processing: Parallel parsing via LSF to extract sgRNA counts
3. Analysis: EdgeR-based differential expression analysis
4. Output: Excel files (counts/stats), PDF reports, delivery-ready results

## File Naming Conventions

- Project files: `Proj_[PROJECT_NUMBER]____[TYPE].xlsx`
- LSF output: `LSF.COUNT/` directory
- Results documentation: `RESULTS.md` → `RESULTS.pdf`

## Development Notes

- Uses LSF job scheduler with specific resource requirements (`-n 5 -W 59`)
- Parser scripts expect gzipped FASTQ files as input
- All Python scripts use `#!/usr/bin/env python3` shebang
- R scripts require specific Excel file patterns to locate input data

## Commit Message Format

Use conventional commits with imperative style, following project-specific guidelines:

### Format Requirements
- Use `type: description` or `type(scope): description`
- Common types: feat, fix, docs, style, refactor, test, chore
- Limit subject+type+scope to 50 characters or less
- Wrap body text at roughly 60 character lines
- Use imperative mood for subject line
- Include reference to specific files or modules when relevant

### Examples
```
fix: resolve memory allocation issue in QC module
```

```
refactor: unify WES and WGS run scripts

Create a single set of scripts that can run multiple job
types using command line options to select type.
```

```
chore(conf): update LSF resource parameters for better performance
```

### Claude Code Commits
- End commit body with `Co-Authored-By: Claude <noreply@anthropic.com>`
- For Cursor AI commits, append `#cursor` tag to last line of body