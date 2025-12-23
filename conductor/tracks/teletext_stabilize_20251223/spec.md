# Specification: Teletext Pipeline Stabilization

## 1. Overview
This track focuses on creating a stable, well-instrumented foundation for the Teletext decoding pipeline. The goal is to isolate existing logic, document its behavior, and introduce safe Rust boundaries without altering the actual decoding results. This is a prerequisite for any future Rust migration of decoding logic.

## 2. Technical Requirements
- **Data Flow Audit:** Map every step from demuxer through PES packet handling to the ZVBI-based decoder and final subtitle output.
- **Reference Locking:** Create a "golden set" of Teletext stream samples and their corresponding correct outputs to ensure zero regressions.
- **FFI Boundary Definition:** Design a robust, memory-safe interface between C and Rust for future use, focusing initially on non-critical utility functions.

## 3. Success Criteria
- [ ] Comprehensive documentation of the current Teletext pipeline exists.
- [ ] Automated regression tests using golden samples pass with bit-identical results.
- [ ] Rust integration is established via FFI with zero impact on decoding performance or correctness.
- [ ] Clear ownership and error-handling rules are defined for the C/Rust boundary.
