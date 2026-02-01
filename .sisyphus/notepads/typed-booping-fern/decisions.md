# Decisions - typed-booping-fern

## [2026-01-26] Initial Decisions

### Bug 1 Fix Decision
- Use `strdup()` instead of shallow copy for credits text
- Rationale: Deep copy prevents allocator mismatch issues
- Alternative considered: Fix Rust allocator (rejected - requires Rust changes)
