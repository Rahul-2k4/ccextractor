#!/bin/bash

SCRIPT_DIR="/home/rahul/Desktop/ccextractor/.sisyphus"
RESULTS_DIR="$SCRIPT_DIR/test_results"

mkdir -p "$RESULTS_DIR"

echo "========================================================"
echo "CCExtractor Linux/Windows Test Verification Suite"
echo "========================================================"
echo "Timestamp: $(date)"
echo "Results stored in: $RESULTS_DIR/"
echo ""

# First, verify ccextractor binary exists
CCEXTRACTOR="/home/rahul/Desktop/ccextractor/linux/ccextractor"
if [ ! -f "$CCEXTRACTOR" ]; then
  echo "ERROR: ccextractor not found at $CCEXTRACTOR"
  echo "Run: cd /home/rahul/Desktop/ccextractor/linux && ./build"
  exit 1
fi

# Verify truth files exist
TRUTH_DIR="$RESULTS_DIR/truth_files"
if [ ! -d "$TRUTH_DIR" ] || [ -z "$(ls -A $TRUTH_DIR 2>/dev/null)" ]; then
  echo "ERROR: Truth files directory not found or empty: $TRUTH_DIR"
  echo "Run Phase 0.5 to generate truth files first"
  exit 1
fi

echo "Using: $CCEXTRACTOR"
"$CCEXTRACTOR" --version 2>&1 | head -1
echo "Truth files found in: $TRUTH_DIR/"
echo ""

# Run individual test scripts
echo "Running Bug 1 tests..."
bash "$SCRIPT_DIR/test_bug1.sh"
echo ""
echo "Running Bug 2 tests..."
bash "$SCRIPT_DIR/test_bug2.sh"
echo ""
echo "Running Bug 3 tests..."
bash "$SCRIPT_DIR/test_bug3.sh"

echo ""
echo "========================================================"
echo "ALL TESTS COMPLETE"
echo "========================================================"
echo "Results saved to: $RESULTS_DIR/"
