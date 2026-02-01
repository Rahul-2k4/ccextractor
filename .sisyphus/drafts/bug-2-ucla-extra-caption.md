# Draft: Bug 2 Investigation - UCLA Extra Caption

## Date: 2026-01-27

## Bug Description
**Test**: 37 with `--ucla` mode
**Issue**: Extra caption at `19700101000000.000` (Unix epoch + 0ms) at start of output
**Expected**: First caption should start at `19700101000002.252` (2.252s from file start)

## Sample File
- Path: `/home/rahul/Desktop/Sample_platform_test_samples/dab1c1bd6576764d92e734abc137c7a390f6aefa2a946e9304bdecc88d4325f9.mpg`

## Investigation Questions

1. What subtitle is being written at `19700101000000.000`?
2. Does it have real content or is it stale buffer data?
3. Why is `start_time = 0` instead of `2252`?
4. Why doesn't `prev_start` logic prevent this spurious write?

## Plan's Investigation Path (from Task 2.1)

**Step 1**: Trace timestamp flow in `ccx_encoders_transcript.c`
**Step 2**: Check prev_start logic
**Step 3**: Search for subtitle caching/buffering
**Step 4**: Check decoder to encoder handoff
**Step 5**: Add debug logging (if needed)

## Progress
- Phase 0: Setup - COMPLETED
- Phase 1: Bug 1 - BLOCKED (complex Rust/C FFI timing issue)
- Phase 2: Bug 2 - INVESTIGATING

## Current Findings

### Output Analysis
```
Line 1: 19700101000000.000|19700101000002.118|CC1|RU2| BEEN HIS WHOLE
Line 2: 19700101000002.118|19700101000002.552|CC1|RU2|CAREER.
Line 3: 19700101000002.552|19700101000004.354|CC1|RU2|WADE SAYS...
```

### Root Cause
**Bug 2 is a SYMPTOM of Bug 1!**

The text "BEEN HIS WHOLE" at timestamp 0 should actually be part of caption "BEEN HIS WHOLE CAREER." that should start at ~2.252s.

**Evidence**:
- Text "BEEN HIS WHOLE" (line 1) + "CAREER." (line 2) = "BEEN HIS WHOLE CAREER."
- Line 1 starts at 00.000s (wrong)
- Line 2 starts at 02.118s (end of same caption)
- Expected: Single caption at 02.252s: "BEEN HIS WHOLE CAREER."

### Technical Explanation
1. Bug 1 causes `context->current_visible_start_ms = 0` for first roll-up caption
2. `write_cc_buffer()` sets `start_time = 0` (line 314)
3. Transcript encoder receives subtitle with `start_time = 0`
4. Guard condition allows write (no `SUB_EOD_MARKER` for CEA-608):
   ```c
   if (context->prev_start != -1 || !(sub->flags & SUB_EOD_MARKER))
   ```
   - `prev_start == -1` (not set yet)
   - `!(sub->flags & SUB_EOD_MARKER)` → TRUE
   - Condition: `FALSE || TRUE` → **TRUE** (writes subtitle with timestamp 0!)
5. Text gets written at `19700101000000.000` (Unix epoch)

### Proposed Fix
Skip subtitles with `start_time = 0` in transcript encoder:

```c
// In write_cc_subtitle_as_transcript(), add check after line 29:
if (start_time == 0 && !sub->info[0])  // Skip if timestamp is epoch AND no mode info
{
    mprint("DEBUG: Skipping subtitle with start_time=0 and empty info\n");
    continue;
}
```

Or modify guard condition to require non-zero start_time:
```c
// FROM line 27:
if (context->prev_start != -1 || !(sub->flags & SUB_EOD_MARKER))

// TO:
if ((context->prev_start != -1 && start_time > 0) || !(sub->flags & SUB_EOD_MARKER))
```

## Decision Point
**Option A**: Fix Bug 2 (symptom) by skipping subtitles with `start_time = 0`
- Pro: Fixes spurious caption at timestamp 0
- Con: Doesn't fix root cause (Bug 1)
- Con: Would need separate fix for Bug 1 later

**Option B**: Focus on Bug 1 (root cause) which would also fix Bug 2
- Pro: Single fix addresses both issues
- Con: Requires investigating Rust/C FFI timing boundary (complex)
- Con: Bug 1 is BLOCKED due to complexity

**Option C**: Quick fix for Bug 2 now, revisit Bug 1 later
- Pro: Progress on plan continues
- Pro: Clear path forward
- Con: Tech debt (Bug 1 still exists)

## Recommendation
Implement **Option C** - quick fix for Bug 2 to unblock progress, document Bug 1 as known issue.
