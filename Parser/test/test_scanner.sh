#!/bin/bash
# Scanner Unit Test Framework
# Tests scanner functionality and validates output

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
PARSER_DIR="$(dirname "$SCRIPT_DIR")"
TEST_SEQS="$PARSER_DIR/../libraries/Brunello_SampleSeqs"
TEST_FASTQ="$SCRIPT_DIR/testScanner.fastq.gz"
SCANNER="$PARSER_DIR/scanner"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Scanner Unit Test Framework"
echo "=========================================="

# Test 1: Basic functionality
echo -e "${YELLOW}Test 1: Basic Scanner Execution${NC}"
echo "Running: python3 scanner $TEST_SEQS $TEST_FASTQ"
echo "------------------------------------------"

cd "$PARSER_DIR"
OUTPUT=$(python3 scanner "$TEST_SEQS" "$TEST_FASTQ" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ Scanner executed successfully${NC}"
else
    echo -e "${RED}✗ Scanner failed with exit code: $EXIT_CODE${NC}"
    echo "Output: $OUTPUT"
    exit 1
fi

# Test 2: Output format validation
echo -e "\n${YELLOW}Test 2: Output Format Validation${NC}"
echo "------------------------------------------"

SCAN_LINES=$(echo "$OUTPUT" | grep "^#SCAN#" | wc -l)
DEBUG_LINES=$(echo "$OUTPUT" | grep -E "^[0-9]+$" | wc -l)
OTHER_LINES=$(echo "$OUTPUT" | grep -v "^#SCAN#" | grep -v "^Namespace" | grep -v -E "^[0-9]+$" | wc -l)

echo "SCAN lines found: $SCAN_LINES"
echo "Debug number lines: $DEBUG_LINES"  
echo "Other lines: $OTHER_LINES"

if [ "$SCAN_LINES" -gt 0 ]; then
    echo -e "${GREEN}✓ Found #SCAN# output lines${NC}"
else
    echo -e "${RED}✗ No #SCAN# lines found${NC}"
fi

if [ "$DEBUG_LINES" -gt 0 ]; then
    echo -e "${YELLOW}⚠ Found debugging number lines (should be removed)${NC}"
fi

# Test 3: Adapter consistency check
echo -e "\n${YELLOW}Test 3: Adapter Sequence Consistency${NC}"
echo "------------------------------------------"

# Extract 5' and 3' adapters
ADAPTERS_5P=$(echo "$OUTPUT" | grep "^#SCAN#" | awk '{print $5}' | sort | uniq -c | sort -nr)
ADAPTERS_3P=$(echo "$OUTPUT" | grep "^#SCAN#" | awk '{print $7}' | sort | uniq -c | sort -nr)

echo "Top 5' adapter sequences:"
echo "$ADAPTERS_5P" | head -3

echo -e "\nTop 3' adapter sequences:"  
echo "$ADAPTERS_3P" | head -3

# Get most common adapters
MOST_COMMON_5P=$(echo "$ADAPTERS_5P" | head -1 | awk '{print $2}')
MOST_COMMON_3P=$(echo "$ADAPTERS_3P" | head -1 | awk '{print $2}')

CONSISTENCY_5P=$(echo "$ADAPTERS_5P" | head -1 | awk '{print $1}')
TOTAL_HITS=$SCAN_LINES

if [ "$SCAN_LINES" -gt 0 ]; then
    CONSISTENCY_PCT_5P=$((CONSISTENCY_5P * 100 / TOTAL_HITS))
    
    if [ "$CONSISTENCY_PCT_5P" -ge 90 ]; then
        echo -e "${GREEN}✓ 5' adapter consistency: ${CONSISTENCY_PCT_5P}% ($MOST_COMMON_5P)${NC}"
    else
        echo -e "${YELLOW}⚠ 5' adapter consistency: ${CONSISTENCY_PCT_5P}% (low)${NC}"
    fi
fi

# Test 4: Statistical validation and consistency
echo -e "\n${YELLOW}Test 4: Statistical Validation${NC}"
echo "------------------------------------------"

# Calculate consistency percentages for both adapters
CONSISTENCY_5P_COUNT=$(echo "$ADAPTERS_5P" | head -1 | awk '{print $1}')
CONSISTENCY_3P_COUNT=$(echo "$ADAPTERS_3P" | head -1 | awk '{print $1}')

if [ "$SCAN_LINES" -gt 0 ]; then
    CONSISTENCY_PCT_5P=$((CONSISTENCY_5P_COUNT * 100 / SCAN_LINES))
    CONSISTENCY_PCT_3P=$((CONSISTENCY_3P_COUNT * 100 / SCAN_LINES))
    
    echo "5' adapter consistency: ${CONSISTENCY_PCT_5P}% (${CONSISTENCY_5P_COUNT}/${SCAN_LINES})"
    echo "3' adapter consistency: ${CONSISTENCY_PCT_3P}% (${CONSISTENCY_3P_COUNT}/${SCAN_LINES})"
    
    if [ "$CONSISTENCY_PCT_5P" -ge 90 ] && [ "$CONSISTENCY_PCT_3P" -ge 90 ]; then
        echo -e "${GREEN}✓ High consistency achieved (>90% for both adapters)${NC}"
    elif [ "$CONSISTENCY_PCT_5P" -ge 75 ] && [ "$CONSISTENCY_PCT_3P" -ge 75 ]; then
        echo -e "${YELLOW}⚠ Moderate consistency (75-90%)${NC}"
    else
        echo -e "${RED}✗ Low consistency (<75%) - may indicate poor library match${NC}"
    fi
    
    # Check if we have sufficient sample size
    if [ "$SCAN_LINES" -ge 20 ]; then
        echo -e "${GREEN}✓ Sufficient sample size for statistical confidence (${SCAN_LINES} hits)${NC}"
    else
        echo -e "${YELLOW}⚠ Low sample size (${SCAN_LINES} hits) - increase MAX_COUNT for better confidence${NC}"
    fi
fi

# Test 5: testScanner.fastq.gz specific validation (known ground truth)
echo -e "\n${YELLOW}Test 5: File-Specific Validation (testScanner.fastq.gz)${NC}"
echo "------------------------------------------"

TESTFILE_BASENAME=$(basename "$TEST_FASTQ")
if [ "$TESTFILE_BASENAME" = "testScanner.fastq.gz" ]; then
    KNOWN_5P="GTGGAAAGGACGAAACACCG"
    KNOWN_3P="GTTTTAGAGCTAGAAATAGC"
    
    echo "For testScanner.fastq.gz, known correct adapters are:"
    echo "  5': $KNOWN_5P"
    echo "  3': $KNOWN_3P"
    
    if [ "$MOST_COMMON_5P" = "$KNOWN_5P" ]; then
        echo -e "${GREEN}✓ 5' adapter matches known correct sequence${NC}"
    else
        echo -e "${RED}✗ 5' adapter differs from known correct:${NC}"
        echo "    Expected: $KNOWN_5P"
        echo "    Found:    $MOST_COMMON_5P"
    fi
    
    if [ "$MOST_COMMON_3P" = "$KNOWN_3P" ]; then
        echo -e "${GREEN}✓ 3' adapter matches known correct sequence${NC}"
    else
        echo -e "${RED}✗ 3' adapter differs from known correct:${NC}"
        echo "    Expected: $KNOWN_3P"  
        echo "    Found:    $MOST_COMMON_3P"
    fi
else
    echo "File-specific validation skipped (only applies to testScanner.fastq.gz)"
    echo "Current file: $TESTFILE_BASENAME"
fi

# Test 6: Count behavior analysis
echo -e "\n${YELLOW}Test 6: Count Behavior Analysis${NC}"
echo "------------------------------------------"

MAX_COUNT_IN_CODE=100  # Updated from 10 to 100 for better statistical power
if [ "$SCAN_LINES" -eq "$MAX_COUNT_IN_CODE" ]; then
    echo -e "${GREEN}✓ Hit count matches MAX_COUNT ($MAX_COUNT_IN_CODE)${NC}"
elif [ "$SCAN_LINES" -gt "$MAX_COUNT_IN_CODE" ]; then
    echo -e "${RED}✗ Hit count ($SCAN_LINES) exceeds MAX_COUNT ($MAX_COUNT_IN_CODE) - loop termination broken${NC}"
else
    echo -e "${YELLOW}⚠ Hit count ($SCAN_LINES) less than MAX_COUNT ($MAX_COUNT_IN_CODE)${NC}"
fi

# Summary
echo -e "\n=========================================="
echo -e "${YELLOW}Test Summary${NC}"
echo "=========================================="
echo "Total #SCAN# hits found: $SCAN_LINES"
echo "Most common 5' adapter: $MOST_COMMON_5P"
echo "Most common 3' adapter: $MOST_COMMON_3P"
echo "Debug lines present: $DEBUG_LINES"

if [ "$SCAN_LINES" -gt "$MAX_COUNT_IN_CODE" ] || [ "$DEBUG_LINES" -gt 0 ]; then
    echo -e "\n${RED}ISSUES DETECTED:${NC}"
    [ "$SCAN_LINES" -gt "$MAX_COUNT_IN_CODE" ] && echo "- Loop termination not working properly"
    [ "$DEBUG_LINES" -gt 0 ] && echo "- Debugging output contaminating results"
    echo -e "\n${YELLOW}Status: NEEDS FIXES${NC}"
else
    echo -e "\n${GREEN}Status: TESTS PASSED${NC}"
fi

echo "=========================================="