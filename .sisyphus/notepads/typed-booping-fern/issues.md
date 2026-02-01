# Issues - typed-booping-fern

## [2026-01-27] Task 1.2 Status Update

### Current Status: BLOCKED ❌

**Problem**: Fix attempts in `ccx_decoders_608.c` are not working. Multiple strategies tried:

1. **Attempt 1**: Added `if (context->current_visible_start_ms == 0)` before `write_cc_buffer()`
   - Result: Still shows `00:00:00,000`
   - Position: AFTER `write_cc_buffer()` - timing set too late

2. **Attempt 2**: Moved fix AFTER `write_cc_buffer()` - still incorrect
   - Result: Still shows `00:00:00,000`
   - Problem: Sets timing for NEXT caption, not current one

3. **Attempt 3**: Added `screenfuls_counter == 0` check
   - Result: Still shows `00:00:00,000`
   - Rationale: Only initialize for first pop-on, not all

4. **Attempt 4**: Added debug logging to trace `current_visible_start_ms` value
   - Result: No debug output appeared - condition never triggered?

### Current Output Comparison

| Metric | Linux (buggy) | Windows (reference) | Difference |
|--------|------------------|-------------------|------------|
| First subtitle start | `00:00:00,000` | `00:00:13,713` | 13,713 ms |
| Number of subtitles | 1 | 2 | - |
| Output size | 104 bytes | 162 bytes | - |

### Root Cause Hypothesis (Revised)

The issue may be in **Rust timing layer** (`ccxr_get_visible_start()`), NOT in C decoder:

**Function Chain**:
```
ccx_decoders_608.c:
  start_time = context->current_visible_start_ms (line 314)
  ↓
  current_visible_start_ms set by get_visible_start() (line 880)
  ↓
  get_visible_start() → ccxr_get_visible_start() (Rust FFI)
  ↓
  Returns: fts_now + fts_global
```

**If `fts_now = 0`** (because `min_pts` not set yet):
- First call to `get_visible_start()` returns: `0 + 0 = 0` or `0 + 0 + 1 = 1`
- Result: `start_time = 0` or `1`

**Question**: Why does Windows get `fts_now = ~13713` but Linux gets `fts_now = 0`?

### Required Investigation

**Need to investigate**:
1. When is `min_pts` actually set in Rust timing code?
2. What triggers `fts_now` to become non-zero?
3. Is there platform-specific timing initialization?
4. Why does Windows first subtitle start at ~13.7s (matching PTS: `00:00:13,311`)?
5. Does Linux have different timing sync behavior?

### Files to Examine

1. **`src/rust/lib_ccxr/src/time/timing.rs`** - Core timing logic
2. **`src/rust/src/libccxr_exports/time.rs`** - FFI bindings
3. **`src/lib_ccx/ccx_common_timing.c`** - C timing wrapper
4. **TS stream demuxer** - Where PTS is extracted and timing initialized

### Proposed Next Step

**Investigate Rust timing initialization** rather than trying more fixes in C decoder.

The simple fix in `ccx_decoders_608.c` cannot work if `get_visible_start()` itself returns the wrong value (0 or 1) because `fts_now` is 0.

### Git Status

```
Modified: src/lib_ccx/ccx_decoders_608.c
Commit: ca0350bc - "fix(608): add screenfuls_counter check to prevent re-initializing..."
Status: Fix doesn't work
```

---

## Recommendation to User

**Option 1**: Continue investigating Rust timing layer
- Investigate when `min_pts` is set and how `fts_now` becomes valid
- Understand why Windows gets correct timing (~13.7s) but Linux doesn't
- Find platform-specific timing initialization code

**Option 2**: Skip Task 1.2 (mark as blocked) and move to Task 1.3 (Build & Test)
- Document that fix attempts failed
- Proceed to test anyway (knowing it will fail)
- This allows plan to complete even if bug isn't fixed

**Option 3**: Abandon Bug 1 investigation
- Document findings and move to Bugs 2 and 3
- This respects "solely on bug 1" constraint but acknowledges it's not fixable with current approach

**What would you like to do?**
