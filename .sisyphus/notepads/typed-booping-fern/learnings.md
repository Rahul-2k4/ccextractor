# Learnings: Bug 1 Fix Investigation

## [2026-01-28] Session Start

### Context
- Plan Review: Validating fixes from `/home/rahul/.claude/plans/typed-booping-fern.md`
- Active Boulder: Using `.sisyphus/plans/typed-booping-fern.md`
- Issue: Bug 1 - Credits not appearing for CEA-708 subtitles

---

## Bug 1 - Plan B Analysis (CEA-708 Credits Fix)

### What Plan B Proposes

**Issue**: CEA-708 output path bypasses `try_to_add_start_credits()` call

**Fix**:
1. Add `try_to_add_start_credits()` declaration to `ccx_encoders_common.h`
2. Add credits check to `dtvcc_write()` in `ccx_decoders_708_output.c`

### Findings

**Fix Status**: ✅ ALREADY IMPLEMENTED in codebase!

1. **Function exists**: `try_to_add_start_credits()` at `src/lib_ccx/ccx_encoders_common.c:482`
2. **Function declared**: Declaration at `src/lib_ccx/ccx_encoders_common.h:225`
3. **Credits check exists**: `dtvcc_write()` calls it at lines 623-628

### Test Results

**Command**: `./linux/ccextractor <sample> --startcreditstext "CCextractor Start crdit Testing" -o test226.p1.svc01.srt`

**Without debug flags**:
```
1
00:00:13,713 --> 00:00:14,414
>> WHICH OF THESE STORIES WILL
```
- **Status**: ⚠️ Timing is CORRECT (13.713s)
- **Issue**: Credits text "CCextractor Start crdit Testing" is MISSING

**With `--debug --608` flags**:
```
1
00:00:00,000 --> 00:00:14,980
>> WHICH OF THESE STORIES WILL  
YOU BE TALKING ABOUT TRO        
```
- **Status**: ❌ Timing is WRONG (back to 0:00:00,000)
- **Issue**: Credits STILL MISSING

### Root Cause Analysis

**Critical Finding**: Adding `--debug --608` flags BREAKS the timing!

**Suspected Issue**:
1. Debug flags might interfere with timing calculation or flow
2. `try_to_add_start_credits()` might not be executing due to guard conditions
3. Credits check at `dtvcc_write():623-628` exists but may not be triggered

**Alternative Hypothesis**:
The Active Boulder plan (`.sisyphus/plans/typed-booping-fern.md`) is working on the **PRIMARY issue**: fixing timing at `general_loop.c`. This is the CORRECT fix for:

- Test 226.srt (CEA-608): First subtitle at 00:00:00,000 (NEEDS FIX)
- Plan B addresses CEA-708 credits, which is SECONDARY

### Test Output Files

**Two files generated from test 226**:
- `test226.srt` (CEA-608): Has timing issue (00:00:00,000)
- `test226.p1.svc01.srt` (CEA-708): Has timing correct (00:00:13,713), missing credits

### Conclusion

**PLAN B (CEA-708 credits fix)** is **NOT READY** for implementation:

1. ✅ Code changes already exist
2. ❌ Fix doesn't work when tested (credits don't appear)
3. ❌ Adding debug flags makes timing WORSE, not better

**Primary Problem Remains**: The timing fix at `general_loop.c` (Active Boulder task) is the CORRECT approach and should be the priority.

---

## Recommendation

**Focus on Active Boulder Plan** (`.sisyphus/plans/typed-booping-fern.md`):

1. Fix CEA-608 timing issue at `general_loop.c` or `ts_functions.c`
2. Verify timing fix works for CEA-608 output
3. CEA-708 credits issue may resolve automatically once timing is correct

**Plan B Status**: Deferred - requires investigation into why debug flags break timing and why credits check doesn't execute.

---

## Key Questions Remaining

1. Why does adding `--debug --608` break CEA-708 timing (00:00:00,000)?
2. Why does `try_to_add_start_credits()` call appear to not execute even though code exists?
3. Is there a better approach to fixing CEA-708 credits that doesn't conflict with timing logic?

## Next Steps

**Investigate Active Boulder plan approach** to fix CEA-608 timing issue in `ts_functions.c` or `general_loop.c`.
