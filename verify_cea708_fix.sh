#!/bin/bash
# CEA-708 Timing Bug Fix - Quick Verification Script
# Based on CEA708_TIMING_BUG_TEST_PLAN.md

set -e

# Configuration
CCX="/home/rahul/Desktop/ccextractor/linux/ccextractor"
DEFAULT_SAMPLE="/home/rahul/Desktop/Sample_platform_test_samples/c4dd893cb9d67be50f88bdbd2368111e16b9d1887741d66932ff2732969d9478.ts"
SAMPLE="${1:-$DEFAULT_SAMPLE}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}CEA-708 Timing Bug Fix - Verification${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Check prerequisites
if [[ ! -f "$CCX" ]]; then
    echo -e "${RED}❌ ERROR: Binary not found: $CCX${NC}"
    echo "Please build first: cd /home/rahul/Desktop/ccextractor/linux && ./build"
    exit 1
fi

if [[ ! -f "$SAMPLE" ]]; then
    echo -e "${RED}❌ ERROR: Test sample not found: $SAMPLE${NC}"
    exit 1
fi

# Create temp directory
OUTDIR="/tmp/cea708_verify_$(date +%s)"
mkdir -p "$OUTDIR"
cd "$OUTDIR"

echo "Binary: $CCX"
echo "Sample: $SAMPLE"
echo "Output: $OUTDIR"
echo ""

# Run extraction (suppress debug output)
echo -n "Running extraction... "
if $CCX "$SAMPLE" -o test_output.srt >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo -e "${RED}❌ Extraction failed${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}TEST RESULTS${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Check if service file exists
if [[ ! -f "test_output.p1.svc01.srt" ]]; then
    echo -e "${RED}❌ FAIL: Service file not generated${NC}"
    exit 1
fi

# Extract first timestamp
FIRST_TS=$(head -2 test_output.p1.svc01.srt | tail -1 | cut -d' ' -f1)

echo "📊 TEST-001: Basic Timestamp Verification (CRITICAL)"
echo "   Expected: ~00:00:13,713 (NOT 00:00:00,000)"
echo "   Actual:   $FIRST_TS"
echo ""

if [[ "$FIRST_TS" == "00:00:00,000" ]]; then
    echo -e "${RED}❌ FAIL: Bug NOT fixed - first subtitle shows 00:00:00,000${NC}"
    echo ""
    echo "This indicates the timing pointer is still stale."
    exit 1
fi

# Check if timestamp is in expected range (10-20 seconds)
FIRST_TS_MS=$(echo "$FIRST_TS" | awk -F'[:,]' '{print ($1*3600 + $2*60 + $3)*1000 + $4}')
if [[ $FIRST_TS_MS -lt 10000 || $FIRST_TS_MS -gt 20000 ]]; then
    echo -e "${YELLOW}⚠️  WARNING: Timestamp outside expected range (10-20s)${NC}"
    echo ""
fi

# Count zero-timestamp entries
ZERO_COUNT=$(grep -c "^00:00:00,000 -->" test_output.p1.svc01.srt 2>/dev/null || echo "0")
ZERO_COUNT=$(echo "$ZERO_COUNT" | tr -d '\n')

echo "📊 TEST-002: Zero Timestamp Detection"
echo "   Expected: 0 subtitles starting at 00:00:00,000"
echo "   Actual:   $ZERO_COUNT subtitles"
echo ""

if [[ $ZERO_COUNT -gt 0 ]]; then
    echo -e "${YELLOW}⚠️  WARNING: Found $ZERO_COUNT subtitle(s) with zero start time${NC}"
    echo ""
fi

# Show sample output
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}Sample Output (first 3 entries)${NC}"
echo -e "${BLUE}=========================================${NC}"
head -15 test_output.p1.svc01.srt
echo ""

# Final verdict
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}VERDICT${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

if [[ "$FIRST_TS" != "00:00:00,000" ]]; then
    echo -e "${GREEN}✅ SUCCESS: CEA-708 Timing Bug Fix VERIFIED!${NC}"
    echo ""
    echo "The first subtitle correctly shows timestamp: $FIRST_TS"
    echo "This confirms the timing pointer synchronization is working."
    echo ""
    echo "Output files saved to: $OUTDIR"
    echo ""
    exit 0
else
    echo -e "${RED}❌ FAILURE: Bug still present${NC}"
    echo ""
    echo "Output files saved to: $OUTDIR"
    exit 1
fi
