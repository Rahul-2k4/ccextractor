# Product Guidelines: CCExtractor

## 1. Communication Style
- **Technical & Precise:** All user-facing text (CLI help, logs, errors, and documentation) MUST prioritize technical accuracy and determinism. Marketing language, vague assertions, and subjective phrasing are prohibited.
- **Actionable Feedback:** Error messages MUST include concrete diagnostic context when available (e.g., stream ID, PID, byte offset, timestamp, codec type). Errors that lack actionable data must explicitly state that the information is unavailable.

## 2. CLI Design Principles
- **Explicit Flags:** Long, descriptive flags (e.g., `--input-format`) are the primary interface. Short flags may exist only as aliases and must never introduce unique behavior.
- **Backward Compatibility:** Existing CLI flags MUST NOT change behavior. Any incompatible change requires a documented, versioned deprecation cycle with warnings emitted for at least one stable release.
- **Predictable Output:** Maintain a "Reliable Workhorse" personality. Default output MUST be plain ASCII text, stable under redirection, and safe for log aggregation. Decorative elements (colors, progress bars, animations) are forbidden unless explicitly enabled by a flag.

## 3. Logging & Diagnostics
- **Hierarchical Logging:** All logging MUST use standardized levels (ERROR, WARN, INFO, DEBUG, TRACE). Each level has a defined audience: ERROR/WARN for users, INFO for operational context, DEBUG/TRACE for diagnostics. Logs MUST include consistent, machine-filterable prefixes.
- **Unified Error Reporting:** Rust components MUST translate all internal errors into the core C error model. Rust panics, native backtraces, or language-specific error formats MUST NOT cross FFI boundaries.

## 4. User Experience (UX) for Engineers
- **Deterministic Behavior:** Given the same input, flags, and environment, CCExtractor MUST produce identical outputs and log messages across runs, barring explicitly documented non-deterministic modes.
- **Automation-First Design:** All features MUST assume non-interactive usage as part of automated pipelines. stdout and stderr semantics must remain stable, minimal, and script-safe.
