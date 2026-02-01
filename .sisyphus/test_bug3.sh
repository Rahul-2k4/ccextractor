#!/bin/bash
# NO set -e - we want to continue even if ccextractor fails

CCEXTRACTOR="/home/rahul/Desktop/ccextractor/linux/ccextractor"
SAMPLE="/home/rahul/Desktop/Sample_platform_test_samples/29e5ffd34b3917c445fb89355934cd12187d165ca34b02303feb24a954513b30.ts"
OUTPUT_DIR="/home/rahul/Desktop/ccextractor/.sisyphus/test_results/outputs"
TRUTH_DIR="/home/rahul/Desktop/ccextractor/.sisyphus/test_results/truth_files"

mkdir -p "$OUTPUT_DIR"

echo "============================================"
echo "BUG 3 VERIFICATION: 50ms timing variance"
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

if [ ! -f "$TRUTH_DIR/test136_truth.srt" ]; then
  echo "❌ ERROR: Truth file not found at $TRUTH_DIR/test136_truth.srt"
  echo "   Run Phase 0.5 to generate truth files first"
  exit 1
fi

echo "[TEST 136] --out=srt --latin1 --autoprogram"
if "$CCEXTRACTOR" "$SAMPLE" \
  --out=srt --latin1 --autoprogram \
  -o "$OUTPUT_DIR/test136.srt" 2>/dev/null; then
  echo "   CCExtractor completed successfully"
else
  echo "   ⚠️  CCExtractor returned non-zero exit code"
fi

if [ ! -f "$OUTPUT_DIR/test136.srt" ]; then
  echo "❌ TEST 136 FAILED: No output file produced"
  exit 1
fi

echo "--- Full output ---"
cat "$OUTPUT_DIR/test136.srt"
echo "--- End ---"

# VERIFICATION: Exact hash comparison (maintainer requires ZERO tolerance)
OUTPUT_HASH=$(sha256sum "$OUTPUT_DIR/test136.srt" | cut -d' ' -f1)
TRUTH_HASH=$(sha256sum "$TRUTH_DIR/test136_truth.srt" | cut -d' ' -f1)

echo ""
echo "Hash comparison (exact match required - no tolerance for 50ms drift):"
echo "  Output hash: $OUTPUT_HASH"
echo "  Truth hash:  $TRUTH_HASH"

if [ "$OUTPUT_HASH" = "$TRUTH_HASH" ]; then
  echo "✅ TEST 136 PASSED: Output matches truth file exactly"
  echo "   No timing drift - timestamps match Windows reference"
else
  echo "❌ TEST 136 FAILED: Hash mismatch with truth file"
  echo "   Expected hash (truth): $TRUTH_HASH"
  echo "   Got hash (output):   $OUTPUT_HASH"
  echo ""
  echo "   Maintainer requires ZERO tolerance for timestamp drift."
  echo "   50ms difference = FAILURE, not 'close enough'"
fi

echo ""
echo "============================================"
echo "BUG 3 SUMMARY"
echo "============================================"
echo "Output file saved to: $OUTPUT_DIR/test136.srt"
