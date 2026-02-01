#!/bin/bash
# NO set -e - we want to continue even if ccextractor fails

CCEXTRACTOR="/home/rahul/Desktop/ccextractor/linux/ccextractor"
SAMPLE="/home/rahul/Desktop/Sample_platform_test_samples/c4dd893cb9d67be50f88bdbd2368111e16b9d1887741d66932ff2732969d9478.ts"
OUTPUT_DIR="/home/rahul/Desktop/ccextractor/.sisyphus/test_results/outputs"
TRUTH_DIR="/home/rahul/Desktop/ccextractor/.sisyphus/test_results/truth_files"

mkdir -p "$OUTPUT_DIR"

echo "============================================"
echo "BUG 1 VERIFICATION: --startcreditstext"
echo "============================================"
echo "Timestamp: $(date)"
echo ""

# Verify prerequisites
if [ ! -f "$CCEXTRACTOR" ]; then
  echo "❌ ERROR: ccextractor binary not found at $CCEXTRACTOR"
  echo "   Run: cd /home/rahul/Desktop/ccextractor/linux && ./build"
  exit 1
fi

if [ ! -f "$SAMPLE" ]; then
  echo "❌ ERROR: Sample file not found at $SAMPLE"
  exit 1
fi

if [ ! -f "$TRUTH_DIR/test226_truth.srt" ]; then
  echo "❌ ERROR: Truth files not found in $TRUTH_DIR"
  echo "   Run Phase 0.5 to generate truth files first"
  exit 1
fi

PASS_COUNT=0
FAIL_COUNT=0

# Test 226: Basic startcreditstext
echo "[TEST 226] --startcreditstext basic"
if "$CCEXTRACTOR" "$SAMPLE" \
  --startcreditstext "CCextractor Start crdit Testing" \
  -o "$OUTPUT_DIR/test226.srt" 2>/dev/null; then
  echo "   CCExtractor completed successfully"
else
  echo "   ⚠️  CCExtractor returned non-zero exit code (may still work)"
fi

if [ ! -f "$OUTPUT_DIR/test226.srt" ]; then
  echo "❌ TEST 226 FAILED: No output file produced"
  ((FAIL_COUNT++))
else
  echo "--- First 10 lines of output ---"
  head -10 "$OUTPUT_DIR/test226.srt"
  echo "--- End ---"

  # VERIFICATION: Exact hash comparison (maintainer requires exact match)
  OUTPUT_HASH=$(sha256sum "$OUTPUT_DIR/test226.srt" | cut -d' ' -f1)
  TRUTH_HASH=$(sha256sum "$TRUTH_DIR/test226_truth.srt" | cut -d' ' -f1)

  if [ "$OUTPUT_HASH" = "$TRUTH_HASH" ]; then
    echo "✅ TEST 226 PASSED: Output matches truth file exactly"
    ((PASS_COUNT++))
  else
    echo "❌ TEST 226 FAILED: Hash mismatch with truth file"
    echo "   Expected hash (truth): $TRUTH_HASH"
    echo "   Got hash (output):   $OUTPUT_HASH"
    ((FAIL_COUNT++))
  fi
fi

# Test 227: startcreditstext + startcreditsnotbefore
echo ""
echo "[TEST 227] --startcreditstext + --startcreditsnotbefore 1"
"$CCEXTRACTOR" "$SAMPLE" \
  --startcreditsnotbefore 1 \
  --startcreditstext "CCextractor Start crdit Testing" \
  -o "$OUTPUT_DIR/test227.srt" 2>/dev/null || true

if [ -f "$OUTPUT_DIR/test227.srt" ]; then
  OUTPUT_HASH=$(sha256sum "$OUTPUT_DIR/test227.srt" | cut -d' ' -f1)
  TRUTH_HASH=$(sha256sum "$TRUTH_DIR/test227_truth.srt" | cut -d' ' -f1)

  if [ "$OUTPUT_HASH" = "$TRUTH_HASH" ]; then
    echo "✅ TEST 227 PASSED: Output matches truth file exactly"
    ((PASS_COUNT++))
  else
    echo "❌ TEST 227 FAILED: Hash mismatch with truth file"
    echo "   Expected hash (truth): $TRUTH_HASH"
    echo "   Got hash (output):   $OUTPUT_HASH"
    ((FAIL_COUNT++))
  fi
else
  echo "❌ TEST 227 FAILED: No output file produced"
  ((FAIL_COUNT++))
fi

# Test 228: startcreditstext + startcreditsnotafter
echo ""
echo "[TEST 228] --startcreditstext + --startcreditsnotafter 2"
"$CCEXTRACTOR" "$SAMPLE" \
  --startcreditsnotafter 2 \
  --startcreditstext "CCextractor Start crdit Testing" \
  -o "$OUTPUT_DIR/test228.srt" 2>/dev/null || true

if [ -f "$OUTPUT_DIR/test228.srt" ]; then
  OUTPUT_HASH=$(sha256sum "$OUTPUT_DIR/test228.srt" | cut -d' ' -f1)
  TRUTH_HASH=$(sha256sum "$TRUTH_DIR/test228_truth.srt" | cut -d' ' -f1)

  if [ "$OUTPUT_HASH" = "$TRUTH_HASH" ]; then
    echo "✅ TEST 228 PASSED: Output matches truth file exactly"
    ((PASS_COUNT++))
  else
    echo "❌ TEST 228 FAILED: Hash mismatch with truth file"
    echo "   Expected hash (truth): $TRUTH_HASH"
    echo "   Got hash (output):   $OUTPUT_HASH"
    ((FAIL_COUNT++))
  fi
else
  echo "❌ TEST 228 FAILED: No output file produced"
  ((FAIL_COUNT++))
fi

echo ""
echo "============================================"
echo "BUG 1 SUMMARY"
echo "============================================"
echo "Output files saved to: $OUTPUT_DIR/"
echo "Passed: $PASS_COUNT/3"
echo "Failed: $FAIL_COUNT/3"
