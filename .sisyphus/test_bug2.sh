#!/bin/bash
# NO set -e - we want to continue even if ccextractor fails

CCEXTRACTOR="/home/rahul/Desktop/ccextractor/linux/ccextractor"
SAMPLE="/home/rahul/Desktop/Sample_platform_test_samples/dab1c1bd6576764d92e734abc137c7a390f6aefa2a946e9304bdecc88d4325f9.mpg"
OUTPUT_DIR="/home/rahul/Desktop/ccextractor/.sisyphus/test_results/outputs"
TRUTH_DIR="/home/rahul/Desktop/ccextractor/.sisyphus/test_results/truth_files"

mkdir -p "$OUTPUT_DIR"

echo "============================================"
echo "BUG 2 VERIFICATION: --ucla mode"
echo "============================================"
echo "Timestamp: $(date)"
echo ""

# Verify prerequisites
if [ ! -f "$CCEXTRACTOR" ]; then
  echo "❌ ERROR: ccextractor binary not found"
  exit 1
fi

if [ ! -f "$SAMPLE" ]; then
  echo "❌ ERROR: Sample file not found at $SAMPLE"
  exit 1
fi

if [ ! -f "$TRUTH_DIR/test37_truth.txt" ]; then
  echo "❌ ERROR: Truth file not found at $TRUTH_DIR/test37_truth.txt"
  echo "   Run Phase 0.5 to generate truth files first"
  exit 1
fi

echo "[TEST 37] --autoprogram --out=ttxt --latin1 --ucla"
if "$CCEXTRACTOR" "$SAMPLE" \
  --autoprogram --out=ttxt --latin1 --ucla \
  -o "$OUTPUT_DIR/test37.txt" 2>/dev/null; then
  echo "   CCExtractor completed successfully"
else
  echo "   ⚠️  CCExtractor returned non-zero exit code"
fi

if [ ! -f "$OUTPUT_DIR/test37.txt" ]; then
  echo "❌ TEST 37 FAILED: No output file produced"
  exit 1
fi

echo "--- First 5 lines of output ---"
head -5 "$OUTPUT_DIR/test37.txt"
echo "--- End ---"

# VERIFICATION: Exact hash comparison (maintainer requires exact match)
OUTPUT_HASH=$(sha256sum "$OUTPUT_DIR/test37.txt" | cut -d' ' -f1)
TRUTH_HASH=$(sha256sum "$TRUTH_DIR/test37_truth.txt" | cut -d' ' -f1)

echo ""
echo "Hash comparison (exact match required - no tolerance):"
echo "  Output hash: $OUTPUT_HASH"
echo "  Truth hash:  $TRUTH_HASH"

if [ "$OUTPUT_HASH" = "$TRUTH_HASH" ]; then
  echo "✅ TEST 37 PASSED: Output matches truth file exactly"
else
  echo "❌ TEST 37 FAILED: Hash mismatch with truth file"
  echo "   Expected hash (truth): $TRUTH_HASH"
  echo "   Got hash (output):   $OUTPUT_HASH"
  echo ""
  echo "   Common causes:"
  echo "   - Extra caption at 00:00:00.000 (buffer issue)"
  echo "   - Timing drift or formatting differences"
  echo "   - Content mismatches in caption text"
fi

echo ""
echo "============================================"
echo "BUG 2 SUMMARY"
echo "============================================"
echo "Output file saved to: $OUTPUT_DIR/test37.txt"
