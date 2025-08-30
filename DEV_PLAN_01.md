# Development Plan: PIPE_Brunello.sh Refactoring

## Current State Analysis

The current `PIPE_Brunello.sh` is a command history log with:
- Hardcoded file paths (`/igo/delivery/FASTQ/RUTH_0436_BH3N2HDSXF/...`)
- Hardcoded project mapping file (`meta/Proj_17105_sample_mapping.txt`)
- Hardcoded adapter sequences (`GTGGAAAGGACGAAACACCG GTTTTAGAGCTAGAAATAGC`)
- No error handling or validation
- No configurability for different projects

## Pipeline Architecture Understanding

The pipeline has **two distinct stages**:

### Stage 1: Library Structure Discovery (Scanning)
- **Purpose**: Auto-detect adapter sequences flanking sgRNAs in FASTQ data
- **Input**: FASTQ file + target sequence file (from sgRNA library)
- **Process**: Scanner finds sgRNA sequences and reports flanking regions
- **Output**: Adapter sequences (5' and 3') that become args 3 & 4 for runProject.sh

### Stage 2: Full Project Processing (Counting)
- **Purpose**: Count sgRNA occurrences across all samples
- **Input**: Mapping file + detected adapter sequences from Stage 1
- **Process**: Run parser across all samples with discovered adapters
- **Output**: Count files ready for differential analysis

## Transformation Goals

Transform into a robust, two-stage pipeline script with:
1. **Two-Stage Architecture** - Clear separation of scanning vs counting phases
2. **Automatic Adapter Discovery** - No manual specification of adapter sequences
3. **Configurable parameters** - No hardcoded paths/values
4. **Argument parsing** - Command line interface
5. **Error handling** - Proper exit codes and error messages
6. **Input validation** - Check file existence and prerequisites
7. **Logging** - Progress tracking and debugging info
8. **Documentation** - Usage help and examples

## Development Plan

### Phase 1: Parameter Configuration
- [ ] Add command line argument parsing (`getopts` style for bash)
- [ ] Define **required positional parameters**:
  - `$1` - Sample mapping file path
  - `$2` - Project identifier
- [ ] Define **optional parameters** (with defaults):
  - `--output-dir DIR` - Output directory (default: current)
  - `--library FILE` - sgRNA library file (default: libraries/Brunello_NoDatesLibFile.csv.gz)
  - `--parser SCRIPT` - Parser type (default: Parser/parser_5p3p)
  - `--adapter-5p SEQ` - Force 5' adapter sequence (skip auto-detection)
  - `--adapter-3p SEQ` - Force 3' adapter sequence (skip auto-detection)
  - `--verbose` - Verbose logging
  - `--dry-run` - Show commands without executing

### Phase 2: Core Script Structure
- [ ] Add script header with description and usage
- [ ] Implement `usage()` function showing positional args first, then optional flags
- [ ] Create configuration validation function
- [ ] Add logging functions (`log_info`, `log_error`, etc.)
- [ ] Set up error handling with `set -euo pipefail`

### Phase 3: Path and Environment Setup
- [ ] Auto-detect script directory (`SDIR`)
- [ ] Set up relative paths based on script location
- [ ] Validate ScreenSEQ directory structure
- [ ] Create output directories safely
- [ ] Check for required executables (R, scanner, etc.)

### Phase 4: Two-Stage Pipeline Implementation

#### Stage 1: Library Structure Discovery
- [ ] **Step 1A**: Prepare target sequence file from library
  - Extract sgRNA sequences from library CSV/GZ file
  - Create temporary sequence file for scanner input
  - Handle different library formats (Brunello, GeCKO, custom)
- [ ] **Step 1B**: Scanner execution for adapter discovery
  - Select representative FASTQ file from mapping (first sample)
  - Run scanner with target sequences against FASTQ
  - Capture scanner output with flanking sequence information
- [ ] **Step 1C**: Parse scanner output to extract adapters
  - **NEW SCRIPT NEEDED**: `parse_scanner_output.py/R`
  - Analyze scanner "#SCAN#" output lines
  - Determine consensus 5' and 3' adapter sequences
  - Validate adapter consistency across multiple hits
  - Output discovered adapters for Stage 2

#### Stage 2: Full Project Processing  
- [ ] **Step 2A**: Project execution with runProject.sh
  - Use discovered adapters as args 3 & 4
  - Pass through configured parameters
  - Handle LSF job submission across all samples
- [ ] **Step 2B**: Count file organization
  - Create Counts directory safely
  - Move files with error checking
  - Validate count file generation
- [ ] **Step 2C**: Count joining with R script
  - Use configured library file
  - Handle R script execution errors
  - Generate final count matrices

### Phase 5: Error Handling & Validation
- [ ] **Stage 1 Validation**:
  - Scanner produces meaningful output
  - Adapter sequences are consistent and reasonable length
  - Multiple sgRNA hits confirm same adapter patterns
  - Fallback to manual adapter specification if auto-detection fails
- [ ] **Stage 2 Validation**:
  - LSF jobs complete successfully
  - Count files generated for all samples
  - Count files have expected structure and content
- [ ] **Pre-flight checks**:
  - Mapping file exists and is readable
  - FASTQ files accessible from mapping paths
  - Required tools available (scanner, R, LSF)
  - Library file exists and has expected format
- [ ] **Step validation**:
  - Check each stage completed successfully
  - Validate intermediate file creation
  - Handle partial failures gracefully
- [ ] **Cleanup on failure**:
  - Remove temporary sequence files
  - Clean up partial count files
  - Preserve logs for debugging

### Phase 6: Advanced Features
- [ ] **Resume capability** (skip completed stages)
  - `--resume-from-stage2` - Skip adapter discovery, use cached results
  - When both `--adapter-5p` and `--adapter-3p` provided, skip Stage 1 automatically
- [ ] **Dry-run modes**
  - `--dry-run-scan` - Show what Stage 1 would do
  - `--dry-run-count` - Show what Stage 2 would do
- [ ] **Adapter override options**
  - Individual `--adapter-5p` and `--adapter-3p` flags (already covered above)
  - `--validate-adapters` - Check provided adapters against scanner output
- [ ] **Progress reporting and monitoring**
  - Stage progress indicators
  - LSF job monitoring integration
  - Email notifications (optional)
- [ ] **Output options**
  - `--save-adapters` - Save discovered adapters to file for reuse
  - `--adapter-report` - Generate detailed adapter discovery report

## Implementation Strategy

### Script Interface Design
```bash
# Basic usage with positional args (auto-discover adapters)
./PIPE_Brunello.sh meta/mapping.txt Proj_12345

# Skip adapter discovery (use known adapters) 
./PIPE_Brunello.sh meta/mapping.txt Proj_12345 \
  --adapter-5p "GTGGAAAGGACGAAACACCG" \
  --adapter-3p "GTTTTAGAGCTAGAAATAGC"

# Full custom configuration
./PIPE_Brunello.sh meta/Proj_12345_mapping.txt Proj_12345 \
  --output-dir /path/to/output \
  --library libraries/Custom_Library.csv.gz \
  --parser Parser/parser_5p3p \
  --verbose

# Dry run to see what would be executed
./PIPE_Brunello.sh meta/mapping.txt Proj_12345 --dry-run

# Minimal usage (all defaults)
./PIPE_Brunello.sh meta/mapping.txt Proj_12345
```

### Directory Structure Assumptions
```
ScreenSEQ/
├── PIPE_Brunello.sh          # Main script
├── Parser/                   # Parser tools
├── libraries/                # Reference libraries  
├── bin/                      # Utility scripts
└── meta/                     # Project metadata
```

### Error Handling Strategy
- Exit codes: 0=success, 1=usage error, 2=file error, 3=execution error
- Comprehensive error messages with suggestions
- Log file creation for debugging
- Graceful cleanup of temporary files

## Testing Plan

### Test Cases
1. **Basic functionality** - Standard Brunello run
2. **Parameter validation** - Invalid inputs handled correctly
3. **File handling** - Missing files detected
4. **Error recovery** - Partial failures handled
5. **Different configurations** - Custom libraries, adapters

### Validation Criteria
- [ ] Script runs without hardcoded paths
- [ ] Clear error messages for common issues
- [ ] Successful completion produces expected outputs
- [ ] Help/usage information is clear and accurate
- [ ] Script is portable across different project setups

## New Components Required

### Scanner Output Parser Script
**Location**: `Parser/parse_scanner_output.py` or `bin/parse_scanner_output.R`

**Purpose**: Analyze scanner "#SCAN#" output to extract consensus adapter sequences

**Input**: Scanner stdout with lines like:
```
#SCAN# CATCTTCTTTCACCTGAACG 45 5': GTGGAAAGGACGAAACACCG 3': GTTTTAGAGCTAGAAATAGC
```

**Output**: Adapter sequences for runProject.sh args 3 & 4

**Algorithm**:
1. Parse all "#SCAN#" lines from scanner output
2. Extract 5' and 3' flanking sequences  
3. Find consensus sequences (most frequent)
4. Validate consistency across multiple hits
5. Output final adapter pair

## Risk Assessment

### High Risk Areas
- **Adapter Discovery Reliability** - Scanner may not find consistent patterns
- **Library Format Variations** - Different CSV structures across libraries  
- **LSF integration** - Job submission and monitoring complexity
- **Two-Stage Coordination** - Passing results between stages
- **Path resolution** - Relative vs absolute path handling
- **File discovery** - FASTQ file matching from mapping

### Mitigation Strategies
- **Fallback to manual adapters** if auto-discovery fails
- **Multiple validation checks** for adapter consistency
- **Flexible library parsing** for different formats
- **Extensive testing** with different project structures
- **Clear intermediate files** for debugging stage transitions
- **Verbose logging** for debugging complex two-stage issues