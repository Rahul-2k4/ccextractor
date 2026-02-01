#!/bin/bash
# CEA-708 Timing Bug Fix - Automated Test Script
# Usage: ./test_cea708_timing_fix.sh [path_to_sample.ts]

set -e

# Configuration
CCX="/home/rahul/Desktop/ccextractor/linux/ccextractor"
DEFAULT_SAMPLE="/home/rahul/Desktop/Sample_platform_test_samples/c4dd893cb9d67be50f88bdbd2368111e16b9d1887741d66932ff2732969d9478.ts"
SAMPLE="${1:-$DEFAULT_SAMPLE}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASS=0
FAIL=0
WARN=0

# Create temp directory
OUTDIR="/tmp/cea708_test_$(date +%s)"
mkdir -p $OUTDIR
cd $OUTDIR

echo "========================================="
echo "CEA-708 Timing Bug Fix - Test Suite"
echo "========================================="
echo "Binary: $CCX"
echo "Sample: $SAMPLE"
echo "Output: $OUTDIR"
echo ""

# Check binary exists
if [[ ! -f "$CCX" ]]; then
    echo -e "${RED}❌ FAIL: Binary not found: $CCX${NC}"
    echo "Please build first: cd /home/rahul/Desktop/ccextractor/linux && ./build"
    exit 1
fi

# Check sample exists
if [[ ! -f "$SAMPLE" ]]; then
    echo -e "${RED}❌ FAIL: Test sample not found: $SAMPLE${NC}"
    echo "Usage: $0 [path_to_sample.ts]"
    exit 1
fi

# Run extraction
echo "Running extraction..."
if ! $CCX "$SAMPLE" -o test_output.srt 2>/dev/null; then
    echo -e "${RED}❌ FAIL: Extraction failed${NC}"
    exit 1
fi
echo "✅ Extraction complete"
echo ""

# TEST-001: Basic Timestamp Verification
echo "TEST-001: Basic Timestamp Verification"
if [[ -f "test_output.p1.svc01.srt" ]]; then
    # Get the second line (timestamp line) from the file
    FIRST_TS=$(head -2 test_output.p1.svc01.srt | tail -1 | cut -d' ' -f1)
    echo "  First subtitle timestamp: $FIRST_TS"
    
    if [[ "$FIRST_TS" == "00:00:00,000" ]]; then
        echo -e "  ${RED}❌ FAIL: First subtitle is 00:00:00,000 (bug not fixed)${NC}"
        ((FAIL++))
    elif [[ -z "$FIRST_TS" ]]; then
        echo -e "  ${RED}❌ FAIL: Could not parse first timestamp${NC}"
        ((FAIL++))
    else
        echo -e "  ${GREEN}✅ PASS: First subtitle is $FIRST_TS${NC}"
        ((PASS++))
    fi
else
    echo -e "  ${RED}❌ FAIL: Service file not found${NC}"
    ((FAIL++))
fi

# TEST-002: Zero Timestamp Detection
echo ""
echo "TEST-002: Zero Timestamp Detection"
ZERO_COUNT=$(grep -c "00:00:00,000 --> 00:00:00,000" test_output.p1.svc01.srt 2>/dev/null || echo 0)
if [[ "$ZERO_COUNT" -eq 0 ]]; then
    echo -e "  ${GREEN}✅ PASS: No zero-duration entries${NC}"
    ((PASS++))
else
    echo -e "  ${RED}❌ FAIL: Found $ZERO_COUNT zero-duration entries${NC}"
    ((FAIL++))
fi

# TEST-003: 00:00:00 Start Detection
echo ""
echo "TEST-003: Zero Start Time Detection"
ZERO_START=$(grep -c "^00:00:00,000 -->" test_output.p1.svc01.srt 2>/dev/null || echo 0)
if [[ "$ZERO_START" -eq 0 ]]; then
    echo -e "  ${GREEN}✅ PASS: No subtitles start at 00:00:00,000${NC}"
    ((PASS++))
else
    echo -e "  ${YELLOW}⚠️  WARN: Found $ZERO_START subtitles starting at 00:00:00,000${NC}"
    ((WARN++))
fi

# TEST-004: Hide Time Validation
echo ""
echo "TEST-004: Hide Time Validation"
INVALID_COUNT=$(grep -E "^[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3} --> [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}$" test_output.p1.svc01.srt 2>/dev/null | \
awk -F' --> ' '{
    split($1, s, /[:,]/); split($2, e, /[:,]/);
    start = (s[1]*3600 + s[2]*60 + s[3])*1000 + s[4];
    end = (e[1]*3600 + e[2]*60 + e[3])*1000 + e[4];
    if (end <= start) print "Invalid"
}' | wc -l)

if [[ "$INVALID_COUNT" -eq 0 ]]; then
    echo -e "  ${GREEN}✅ PASS: All hide times are valid${NC}"
    ((PASS++))
else
    echo -e "  ${YELLOW}⚠️  WARN: Found $INVALID_COUNT entries with invalid hide times${NC}"
    ((WARN++))
fi

# TEST-005: Service File Generation
echo ""
echo "TEST-005: Service File Generation"
if [[ -f "test_output.p1.svc01.srt" && -s "test_output.p1.svc01.srt" ]]; then
    SIZE=$(stat -c%s "test_output.p1.svc01.srt" 2>/dev/null || stat -f%z "test_output.p1.svc01.srt" 2>/dev/null || echo "unknown")
    ENTRIES=$(grep -c "^[0-9]\+$" test_output.p1.svc01.srt 2>/dev/null || echo 0)
    echo -e "  ${GREEN}✅ PASS: Service file exists (${SIZE} bytes, ${ENTRIES} entries)${NC}"
    ((PASS++))
else
    echo -e "  ${RED}❌ FAIL: Service file missing or empty${NC}"
    ((FAIL++))
fi

# TEST-006: First Timestamp Range Check
echo ""
echo "TEST-006: First Timestamp Range Check"
if [[ -n "$FIRST_TS" && "$FIRST_TS" != "00:00:00,000" ]]; then
    FIRST_TS_MS=$(echo "$FIRST_TS" | awk -F'[:,]' '{print ($1*3600 + $2*60 + $3)*1000 + $4}')
    if [[ $FIRST_TS_MS -gt 10000 && $FIRST_TS_MS -lt 20000 ]]; then
        echo -e "  ${GREEN}✅ PASS: First subtitle at ${FIRST_TS_MS}ms (within expected 10-20s range)${NC}"
        ((PASS++))
    else
        echo -e "  ${YELLOW}⚠️  WARN: First subtitle at ${FIRST_TS_MS}ms (outside 10-20s range)${NC}"
        ((WARN++))
    fi
else
    echo -e "  ${YELLOW}⚠️  SKIP: Cannot validate timestamp range${NC}"
fi

# TEST-007: SRT Format Validation
echo ""
echo "TEST-007: SRT Format Validation"
if head -1 test_output.p1.svc01.srt 2>/dev/null | grep -qE "^[0-9]+$"; then
    echo -e "  ${GREEN}✅ PASS: Valid SRT format (starts with entry number)${NC}"
    ((PASS++))
else
    echo -e "  ${RED}❌ FAIL: Invalid SRT format${NC}"
    ((FAIL++))
fi

# Show sample output
echo ""
echo "========================================="
echo "Sample Output (test_output.p1.svc01.srt)"
echo "========================================="
head -12 test_output.p1.svc01.srt 2>/dev/null || echo "(file empty or missing)"

# Summary
echo ""
echo "========================================="
echo "Test Summary"
echo "========================================="
echo -e "${GREEN}Passed: $PASS${NC}"
if [[ $WARN -gt 0 ]]; then
    echo -e "${YELLOW}Warnings: $WARN${NC}"
fi
if [[ $FAIL -gt 0 ]]; then
    echo -e "${RED}Failed: $FAIL${NC}"
fi
echo ""

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}✅ ALL CRITICAL TESTS PASSED - Bug fix verified!${NC}"
    echo ""
    echo "Output files are in: $OUTDIR"
    echo ""
    echo "To clean up: rm -rf $OUTDIR"
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED - Review output above${NC}"
    echo ""
    echo "Output files are in: $OUTDIR"
    exit 1
fi
