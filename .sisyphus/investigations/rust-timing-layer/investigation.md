# Rust Timing Layer Investigation - COMPLETE

## Date: 2026-01-27

## Root Cause CONFIRMED

### The Bug is in Rust Timing Initialization, NOT C Decoder

**Issue**: `get_visible_start()` returns `fts_now + fts_global`

**Where fts_now is set**: In `set_fts()` at line 179-180 of `timing.rs`

**The Problem Flow**:
```
TS/MP4 Demuxer: extracts PTS
         ↓
General Loop: calls set_fts(dec_ctx->timing) [TIMING.RS line 179]
         ↓
set_fts(): 
    if self.pts_set == PtsSet::No:
        return true  [NO MIN PTS SET!]
    else if self.pts_set == PtsSet::MinPtsSet:
        if self.current_picture_coding_type == FrameType::IFrame:
            self.min_pts = self.current_pts  [SET FROM FIRST I-FRAME]
            ...
        self.fts_now = (self.current_pts - self.min_pts) + fts_offset
```

**For H.264 streams with unknown frame types**: `min_pts` is NEVER SET from an I-frame!

### Consequences

- `min_pts` stays at initial huge value (`0x01FFFFFFFF`)
- `fts_now` is calculated as: `(huge_value - huge_value) + offset = offset`
- Result: `fts_now ≈ 0` (or small positive offset)
- `get_visible_start()` returns: `fts_now + fts_global ≈ 0` or `minimum_fts + 1`
- First pop-on gets `start_time = 0`

**For TS stream** (our sample):
- No I-frames encountered before first caption (H.264 frame type stays unknown)
- `pts_set` transitions from No → MinPtsSet, but NOT from an I-frame
- `min_pts` remains unset → `fts_now = 0`

### Why Windows Works

Windows output starts at `00:00:13,713` because:
1. **Platform-specific TS demuxer** initializes timing correctly (sets min_pts early)
2. **Or**: Windows has different handling of H.264 streams
3. **PTS values arrive before first caption** → `fts_now` has proper value

## Evidence

**TS demuxer** (Linux): calls `set_fts(dec_ctx->timing)` at stream start
**MP4 demuxer** (Windows): Would call similar initialization

**Rust timing.rs**:
- Line 179: If `pts_set == PtsSet::No`, returns `true` WITHOUT setting `min_pts`
- Only sets `min_pts` when `pts_set == PtsSet::MinPtsSet` and frame is I-frame

## The Real Fix Location

**NOT in `ccx_decoders_608.c`** (my previous attempts were misdirected)

**Actual fix needed**: Ensure `min_pts` is set before `get_visible_start()` is called for first pop-on.

### Possible Approaches

1. **Fix in TS/MP4 demuxer**: Initialize timing earlier (set min_pts from first PTS)
2. **Fix in Rust timing**: Return non-zero default when `min_pts` not set
3. **Fix in C decoder**: Add guard that prevents writing caption until `fts_now > 0`

## Next Steps Required

1. **Choose approach**:
   - Fix in demuxer (affects all H.264 streams, clean solution)
   - OR Fix in Rust timing (affects only streams where min_pts isn't set)

2. **After fix choice**: Implement and test to verify ~13.7s timing

## Recommendation

**Fix in TS/MP4 demuxer** is the **preferred solution** because:
- It's platform-independent
- Affects all streams uniformly
- Simpler than Rust timing changes
- Fixes root cause (no min_pts set)

## Files Identified

- TS demuxer: `src/lib_ccx/ts_functions.c` (set_fts at line 65)
- MP4 demuxer: Check if it has similar initialization
- Rust timing: `src/rust/lib_ccxr/src/time/timing.rs` (set_fts at line 179)

## Status: Investigation Complete - Fix Strategy Needed