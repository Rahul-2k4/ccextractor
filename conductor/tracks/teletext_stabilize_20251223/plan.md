# Plan: Teletext Pipeline Stabilization

## Phase 1: Audit and Documentation
- [ ] Task: Audit existing C code for Teletext handling (PES parsing, ZVBI calls).
- [ ] Task: Create a data-flow diagram showing the Teletext lifecycle in CCExtractor.
- [ ] Task: Document all global state and shared memory used in the Teletext pipeline.
- [ ] Task: Conductor - User Manual Verification 'Audit and Documentation' (Protocol in workflow.md)

## Phase 2: Behavioral Baselining
- [ ] Task: Identify and collect high-quality Teletext samples from known broadcast standards.
- [ ] Task: Generate and lock down "golden" output files (SRT, SAMI, etc.) for each sample.
- [ ] Task: Implement an automated regression test script that compares current output with golden references.
- [ ] Task: Conductor - User Manual Verification 'Behavioral Baselining' (Protocol in workflow.md)

## Phase 3: Rust FFI & Boundary Setup
- [ ] Task: Define the initial FFI header for Rust utilities.
- [ ] Task: Implement a trivial Rust helper function (e.g., bitstream validator) and call it from the C Teletext pipeline.
- [ ] Task: Define error-handling mapping from Rust `Result` to C error codes.
- [ ] Task: Verify that the Rust introduction does not affect performance or decoding accuracy.
- [ ] Task: Conductor - User Manual Verification 'Rust FFI & Boundary Setup' (Protocol in workflow.md)
