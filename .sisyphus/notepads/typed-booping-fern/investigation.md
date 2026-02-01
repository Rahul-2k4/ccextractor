# Bug 1 Investigation Results

## Date: 2026-01-27

## Summary
**Original plan description was INCORRECT.** The actual bug is a timestamp calculation issue, not a credits timing issue.

## Actual vs Expected Outputs

### Windows Reference (CORRECT)
```srt
1
00:00:13,713 --> 00:00:14,414
>> WHICH OF THESE STORIES WILL

2
00:00:14,415 --> 00:00:14,981
>> WHICH OF THESE STORIES WILL
YOU BE TALKING ABOUT TRO
```

### Linux Actual (BUGGY)
```srt
1
00:00:00,000 --> 00:00:14,980
>> WHICH OF THESE STORIES WILL  
YOU BE TALKING ABOUT TRO        
```

## Key Observations
1. **NO credits appear on EITHER platform** - The `--startcreditstext` option doesn't produce visible credits in the output
2. **Timestamp discrepancy**: Linux starts at 0ms, Windows starts at ~13713ms (13.7 seconds difference)
3. **Subtitle merging**: Linux produces 1 giant subtitle, Windows produces 2 properly-timed subtitles
4. **Plan's expected timing (`00:00:04,456`) does NOT match Windows reference (`00:00:13,713`)**

## Root Cause Analysis

### Location
`src/lib_ccx/ccx_decoders_608.c` - Pop-on caption timing initialization

### Flow Analysis
1. `ccx_decoder_608_context_init()` (line 140): Sets `current_visible_start_ms = 0`
2. `COM_RESUMECAPTIONLOADING` (line 740): Sets `mode = MODE_POPON`
3. `write_char()` (line 240): **SKIPS** calling `get_visible_start()` because of `MODE_POPON != context->mode` check
4. `COM_ENDOFCAPTION` (line 877): Calls `write_cc_buffer()` using `current_visible_start_ms = 0` (never updated!)
5. Line 880: **THEN** sets `current_visible_start_ms` for the NEXT caption

### Why the Bug Occurs
For pop-on captions, `current_visible_start_ms` is never set before the first `write_cc_buffer()` call because:
- Pop-on mode uses a hidden buffer that gets characters
- `write_char()` skips setting timing for MODE_POPON
- When `COM_ENDOFCAPTION` fires, it uses the default value of 0

### Why Windows Differs
This is likely a timing race - on Windows, the PTS timing initialization happens before the first pop-on is processed, while on Linux it doesn't get initialized in time.

## The Fix

### File: `src/lib_ccx/ccx_decoders_608.c`
### Location: Lines 874-877 (`COM_ENDOFCAPTION` handler)

**Before** (buggy):
```c
case COM_ENDOFCAPTION: // Switch buffers
    // The currently *visible* buffer is leaving, so now we know its ending
    // time. Time to actually write it to file.
    if (write_cc_buffer(context, sub))
```

**After** (fixed):
```c
case COM_ENDOFCAPTION: // Switch buffers
    // The currently *visible* buffer is leaving, so now we know its ending
    // time. Time to actually write it to file.
    // For pop-on captions, current_visible_start_ms might not be set yet
    // (write_char skips setting it for MODE_POPON). Set it now if needed.
    if (context->current_visible_start_ms == 0)
        context->current_visible_start_ms = get_visible_start(context->timing, context->my_field);
    if (write_cc_buffer(context, sub))
```

## Expected Outcome After Fix
- First subtitle should start at ~13713ms (matching Windows)
- Subtitles should be properly split (2 subtitles instead of 1 merged)

## Plan Update Required
The plan's Bug 1 description needs to be updated:
- **Wrong**: "Credits at wrong timestamp 00:00:00,000 instead of 00:00:04,456"
- **Correct**: "First pop-on subtitle timestamp is 0 instead of ~13713ms due to uninitialized current_visible_start_ms"

## Files Modified
- `src/lib_ccx/ccx_encoders_common.c` - strdup() fix (already applied, unrelated to this bug but still valid for memory safety)

## Files to Modify
- `src/lib_ccx/ccx_decoders_608.c` - The fix described above
