# Changelog

## [Unreleased]

### Added
- CLAUDE.md configuration file for Claude Code development guidance
- Comprehensive commit message guidelines from .cursorrules
- settings.local.json to gitignore for local configuration management

### Changed
- Enhanced documentation with project architecture and command reference
- Integrated Cursor AI rules with Claude Code conventions

### Documentation
- Added CMD.format and RESULTS_EMAIL documentation
- Comprehensive results documentation for ScreenSeq
- Updated README with project overview and usage instructions
- Added VERSION.md with release tracking

## [v1.0.1] - 2025-08-30

### Added
- Python3 migration complete with enhanced parser system
- Multiple parser configurations (5p, 3p, 5p+3p, HomoPoly adapters)
- Scanner tool for sequence analysis with improved formatting
- Comprehensive differential analysis pipeline using edgeR
- Automated delivery system with results packaging
- Quality control statistics and diagnostic plotting
- Support for variable length sgRNA sequences
- Brunello and Human GeCKOv2 library support

### Enhanced
- LSF job scheduler integration for parallel processing
- Robust FASTQ file handling with gzip support
- Multi-lane (R1,R2) run processing capabilities
- Error handling and debugging improvements
- Statistical analysis with comprehensive reporting

### Fixed
- Memory allocation issues in count file processing
- Project number handling in file naming
- Factor of 2 error corrections in statistical calculations
- Sample ID parsing from directory structures
- Empty file handling in count processing

### Reorganized
- Moved libraries to dedicated `libraries/` directory
- Consolidated analysis scripts in `bin/` directory
- Reorganized parser tools in `Parser/` directory
- Moved legacy scripts to `attic/` directory

## Earlier Development

### Python3 Migration (feature/python3)
- Complete transition from legacy system to Python3
- New FASTQ processing utilities with dataclass implementation
- Enhanced argument parsing and error handling
- Improved file I/O with compression support

### Simple Scripts Phase (feature/simpleScripts)
- Initial script-based approach for processing
- Basic adapter trimming and counting functionality
- Library parameter integration
- Foundation for current parser system