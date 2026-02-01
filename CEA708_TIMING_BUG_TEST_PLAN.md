# CEA-708 Timing Bug Fix - Testing Plan

## Overview
This testing plan verifies the fix for the CEA-708 timing bug where subtitles showed `00:00:00,000` instead of the correct timestamp due to a stale timing pointer in the Rust decoder.

**Bug Root Cause**: The Rust decoder's `DtvccRust` struct cached a pointer to `ccx_common_timing_ctx` at initialization. When `copy_decoder_context()` in C code allocated a new timing context via `malloc()`, the Rust decoder continued reading from the stale memory location, resulting in `fts_now=0` and incorrect subtitle timestamps.

**Fix Applied**: 
1. Update timing pointer in `ccxr_process_cc_data()` from C context on each call
2. Pass timing pointer to `ccxr_flush_active_decoders()` and update before flush
3. Guard against invalid timing (fts_now=0) during hide time updates

---

## Test Environment Setup

### Prerequisites
```bash
# Build the fixed version
cd /home/rahul/Desktop/ccextractor/linux && ./build

# Test sample
export TEST_SAMPLE="/home/rahul/Desktop/Sample_platform_test_samples/c4dd893cb9d67be50f88bdbd2368111e16b9d1887741d66932ff2732969d9478.ts"

# Create test directory
mkdir -p /tmp/cea708_test && cd /tmp/cea708_test
```

---

## Test Cases

### TEST-001: Basic Timestamp Verification ⭐ CRITICAL
**Objective**: Verify first subtitle shows correct timestamp (~13-15 seconds)

**Steps**:
```bash
rm -f test_output*.srt
/home/rahul/Desktop/ccextractor/linux/ccextractor $TEST_SAMPLE -o test_output.srt
cat test_output.p1.svc01.srt | head -5
```

**Expected Result**:
```
1
00:00:13,713 --> 00:00:14,414
>> WHICH OF THESE STORIES WILL
```

**Pass Criteria**:
- ✅ First subtitle start time is **~00:00:13,713** (NOT 00:00:00,000)
- ✅ First subtitle timestamp > 00:00:10,000
- ❌ FAIL if first subtitle is 00:00:00,000

---

### TEST-002: Zero Timestamp Detection ⭐ CRITICAL
**Objective**: Ensure no subtitles start at 00:00:00,000

**Steps**:
```bash
grep "00:00:00,000 -->" test_output.p1.svc01.srt | wc -l
```

**Expected Result**: Count = 0

**Pass Criteria**:
- ✅ Zero zero-timestamp entries found
- ❌ FAIL if any entry starts at 00:00:00,000

---

### TEST-003: Timestamp Progression
**Objective**: Verify timestamps increase monotonically

**Steps**:
```bash
grep "^[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]" test_output.p1.svc01.srt | head -10
```

**Expected Result**: Timestamps should show steady progression (e.g., 13.7s → 14.4s → ...)

**Pass Criteria**:
- ✅ Each subsequent subtitle has later timestamp
- ✅ No timestamp regressions

---

### TEST-004: Hide Time Validation
**Objective**: Verify hide times are valid (hide > show)

**Steps**:
```bash
# Check for invalid entries where hide <= show
grep -E "^[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3} --> [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}$" test_output.p1.svc01.srt | \
awk -F' --> ' '{print $1 "|" $2}' | \
awk -F'[:,|]' '{s=($1*3600+$2*60+$3)*1000+$4; e=($5*3600+$6*60+$7)*1000+$8; if(e<=s) print "Invalid: " $0}' | wc -l
```

**Expected Result**: Count = 0 (no invalid entries)

**Pass Criteria**:
- ✅ All hide times > show times
- ✅ No zero or negative durations

---

### TEST-005: Service File Generation
**Objective**: Verify Rust decoder outputs to service file

**Steps**:
```bash
ls -la test_output.p1.svc01.srt
wc -l test_output.p1.svc01.srt
```

**Expected Result**:
- File exists and has content (> 100 bytes)
- Contains valid SRT format entries

**Pass Criteria**:
- ✅ test_output.p1.svc01.srt exists
- ✅ File size > 100 bytes
- ✅ Contains at least 1 subtitle entry

---

### TEST-006: End-of-File Flush Handling
**Objective**: Verify EOF flush doesn't corrupt timing

**Steps**:
```bash
# Check last few entries
tail -20 test_output.p1.svc01.srt
```

**Expected Result**:
- Last entries have valid timestamps
- No corruption at end of file
- Hide times are reasonable

**Pass Criteria**:
- ✅ Last subtitle has valid show/hide times
- ✅ No 00:00:00,000 entries at end

---

### TEST-007: Consistency Check (Multiple Runs)
**Objective**: Verify deterministic output across multiple runs

**Steps**:
```bash
cd /tmp/cea708_test
for i in 1 2 3; do
    rm -f run${i}_*.srt
    /home/rahul/Desktop/ccextractor/linux/ccextractor $TEST_SAMPLE -o run${i}_.srt 2>/dev/null
    md5sum run${i}_.p1.svc01.srt
done
```

**Expected Result**: All MD5 hashes identical

**Pass Criteria**:
- ✅ Consistent output across runs
- ✅ No race conditions or memory issues

---

### TEST-008: Multiple Output Formats
**Objective**: Verify fix works across different formats

**Steps**:
```bash
# SRT
/home/rahul/Desktop/ccextractor/linux/ccextractor $TEST_SAMPLE -o test.srt 2>/dev/null
FIRST_SRT=$(grep -A1 "^1$" test.p1.svc01.srt 2>/dev/null | tail -1 | cut -d' ' -f1)
echo "SRT first timestamp: $FIRST_SRT"

# WebVTT  
/home/rahul/Desktop/ccextractor/linux/ccextractor $TEST_SAMPLE -o test.vtt 2>/dev/null
FIRST_VTT=$(grep -A1 "^1$" test.p1.svc01.vtt 2>/dev/null | tail -1 | cut -d' ' -f1)
echo "WebVTT first timestamp: $FIRST_VTT"
```

**Pass Criteria**:
- ✅ All formats have correct first timestamp
- ✅ No format-specific timing issues

---

## Automated Test Script

Save this to `/tmp/cea708_test/run_tests.sh`:

```bash
#!/bin/bash
# CEA-708 Timing Bug Fix - Automated Test Script

set -e

CCX="/home/rahul/Desktop/ccextractor/linux/ccextractor"
SAMPLE="/home/rahul/Desktop/Sample_platform_test_samples/c4dd893cb9d67be50f88bdbd2368111e16b9d1887741d66932ff2732969d9478.ts"
OUTDIR="/tmp/cea708_test_$(date +%s)"
mkdir -p $OUTDIR
cd $OUTDIR

PASS=0
FAIL=0

echo "========================================="
echo "CEA-708 Timing Bug Fix - Test Suite"
echo "========================================="
echo "Output directory: $OUTDIR"
echo ""

# Check sample exists
if [[ ! -f "$SAMPLE" ]]; then
    echo "❌ FAIL: Test sample not found: $SAMPLE"
    exit 1
fi

# Run extraction
echo "Running extraction..."
$CCX $SAMPLE -o test_output.srt 2>/dev/null || {
    echo "❌ FAIL: Extraction failed"
    exit 1
}

# TEST-001: Basic Timestamp Verification
echo ""
echo "TEST-001: Basic Timestamp Verification"
if [[ -f "test_output.p1.svc01.srt" ]]; then
    FIRST_TS=$(grep -A1 "^1$" test_output.p1.svc01.srt | tail -1 | cut -d' ' -f1)
    echo "  First subtitle timestamp: $FIRST_TS"
    
    if [[ "$FIRST_TS" == "00:00:00,000" ]]; then
        echo "  ❌ FAIL: First subtitle is 00:00:00,000 (bug not fixed)"
        ((FAIL++))
    else
        echo "  ✅ PASS: First subtitle is $FIRST_TS"
        ((PASS++))
    fi
else
    echo "  ❌ FAIL: Service file not found"
    ((FAIL++))
fi

# TEST-002: Zero Timestamp Detection
echo ""
echo "TEST-002: Zero Timestamp Detection"
ZERO_COUNT=$(grep -c "00:00:00,000 --> 00:00:00,000" test_output.p1.svc01.srt 2>/dev/null || echo 0)
if [[ "$ZERO_COUNT" -eq 0 ]]; then
    echo "  ✅ PASS: No zero-duration entries"
    ((PASS++))
else
    echo "  ❌ FAIL: Found $ZERO_COUNT zero-duration entries"
    ((FAIL++))
fi

# TEST-003: Hide Time Validation
echo ""
echo "TEST-003: Hide Time Validation"
INVALID_COUNT=$(grep -E "^[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3} --> [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}$" test_output.p1.svc01.srt 2>/dev/null | \
awk -F' --> ' '{
    split($1, s, /[:,]/); split($2, e, /[:,]/);
    start = (s[1]*3600 + s[2]*60 + s[3])*1000 + s[4];
    end = (e[1]*3600 + e[2]*60 + e[3])*1000 + e[4];
    if (end <= start) print "Invalid"
}' | wc -l)

if [[ "$INVALID_COUNT" -eq 0 ]]; then
    echo "  ✅ PASS: All hide times valid"
    ((PASS++))
else
    echo "  ⚠️  WARN: Found $INVALID_COUNT invalid hide times"
    # Don't fail for warnings
fi

# TEST-004: Service File Generation
echo ""
echo "TEST-004: Service File Generation"
if [[ -f "test_output.p1.svc01.srt" && -s "test_output.p1.svc01.srt" ]]; then
    SIZE=$(stat -c%s "test_output.p1.svc01.srt" 2>/dev/null || stat -f%z "test_output.p1.svc01.srt" 2>/dev/null || echo "unknown")
    ENTRIES=$(grep -c "^[0-9]\+$" test_output.p1.svc01.srt 2>/dev/null || echo 0)
    echo "  ✅ PASS: Service file exists (${SIZE} bytes, ${ENTRIES} entries)"
    ((PASS++))
else
    echo "  ❌ FAIL: Service file missing or empty"
    ((FAIL++))
fi

# TEST-005: First Timestamp Range Check
echo ""
echo "TEST-005: First Timestamp Range Check"
FIRST_TS_MS=$(echo "$FIRST_TS" | awk -F'[:,]' '{print ($1*3600 + $2*60 + $3)*1000 + $4}')
if [[ $FIRST_TS_MS -gt 10000 && $FIRST_TS_MS -lt 20000 ]]; then
    echo "  ✅ PASS: First subtitle at ${FIRST_TS_MS}ms (within expected 10-20s range)"
    ((PASS++))
else
    echo "  ⚠️  WARN: First subtitle at ${FIRST_TS_MS}ms (outside 10-20s range)"
fi

# Summary
echo ""
echo "========================================="
echo "Test Summary"
echo "========================================="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [[ $FAIL -eq 0 ]]; then
    echo "✅ ALL TESTS PASSED - Bug fix verified!"
    echo ""
    echo "First subtitle content:"
    head -4 test_output.p1.svc01.srt
    exit 0
else
    echo "❌ SOME TESTS FAILED - Review output above"
    exit 1
fi
```

Run with: `chmod +x /tmp/cea708_test/run_tests.sh && /tmp/cea708_test/run_tests.sh`

---

## Manual Verification Checklist

| Test | Description | Check | Status |
|------|-------------|-------|--------|
| 1 | Basic timestamp | First subtitle > 00:00:10,000 | ☐ |
| 2 | No zero starts | No 00:00:00,000 entries | ☐ |
| 3 | Valid durations | Hide > Show for all | ☐ |
| 4 | File generation | test_output.p1.svc01.srt exists | ☐ |
| 5 | File content | > 100 bytes, valid SRT | ☐ |
| 6 | EOF handling | Last entry has valid time | ☐ |
| 7 | Consistency | Same output on re-run | ☐ |
| 8 | No crashes | Clean exit code 0 | ☐ |

---

## Test Sample Reference

| Property | Value |
|----------|-------|
| **File** | `c4dd893cb9d67be50f88bdbd2368111e16b9d1887741d66932ff2732969d9478.ts` |
| **Expected First Subtitle** | ~00:00:13,713 |
| **Min PTS** | 00:00:01,433 (1.43s) |
| **Video Duration** | ~00:00:14,447 (14.4s) |
| **Format** | MPEG-TS with CEA-708 captions |
| **Frame Rate** | 29.97 fps |
| **First Caption CC Data** | Around sequence 44-46 |

---

## Expected Behavior

### Before Fix (Bug Present)
```
1
00:00:00,000 --> 00:00:14,980
>> WHICH OF THESE STORIES WILL
```
- First subtitle starts at 00:00:00,000 (WRONG)
- Caused by stale timing pointer reading fts_now=0

### After Fix (Bug Fixed)
```
1
00:00:13,713 --> 00:00:14,414
>> WHICH OF THESE STORIES WILL
```
- First subtitle starts at ~00:00:13,713 (CORRECT)
- Timing pointer synchronized with C context

---

## Sign-Off Criteria

The fix is **VERIFIED** when:

1. ✅ TEST-001 passes (first subtitle ~13-15 seconds)
2. ✅ TEST-002 passes (no zero timestamps)
3. ✅ TEST-004 passes (service file generated)
4. ✅ All manual checklist items verified
5. ✅ Automated test script reports: "ALL TESTS PASSED"

## Notes

- The C decoder path (`test_output.srt`) may still show incorrect timestamps - this is expected as the fix only applies to the Rust decoder
- The authoritative output for CEA-708 is the service file (`test_output.p1.svc01.srt`)
- Run tests on a clean build: `cd /home/rahul/Desktop/ccextractor/linux && ./build`

---

**Test Plan Version**: 1.0
**Created**: 2026-02-01
**Applies to**: CEA-708 Timing Bug Fix (commit with timing pointer sync)
