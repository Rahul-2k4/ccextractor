# Initial Concept
CCExtractor is an open-source subtitle and closed-caption extraction engine focused on deterministic, broadcast-grade accuracy across diverse video formats and transmission standards.

# Product Guide: CCExtractor

## 1. Vision & Purpose
CCExtractor aims to remain the de facto open-source reference for subtitle extraction, prioritizing reliability and performance for accessibility and language learning.

The project is undergoing a controlled, incremental transition from a legacy C core to Rust.

## 2. Target Audience
- **Individual Users:** Archiving and personal media workflows.
- **Accessibility & Education:** Compliance-focused users and language-learning platforms.
- **Media Engineering Teams:** Broadcast, OTT, and archival pipelines requiring automation, accuracy, and long-term stability.

## 3. Core Development Goals
1.  **Rust Migration:** Incrementally migrate safety-critical and high-maintenance components to Rust while preserving the existing C ABI and CLI behavior.
2.  **OCR & Hardsub Processing:** Improve accuracy, speed, and language model extensibility for burned-in subtitles, with reproducible benchmarking.
3.  **Build & Dependency Modernization:** Provide deterministic, cross-platform builds with minimal manual setup using standardized tooling.
4.  **Broadcast Standards:** Maintain and improve compliance with DVB-S/T/C and CEA-608/CEA-708 captioning standards.

All core development goals are enforced through code review, CI, and backward compatibility requirements.

## 4. Core Capabilities & Architecture

### Core Capabilities
- **Multi-Format Extraction:** Support for a wide range of input formats (TS, MP4, MKV, etc.) and subtitle standards.
- **Real-Time Processing:** Capabilities for live stream subtitle extraction and processing.

### Architecture
- **Hybrid Design:** A hybrid C/Rust architecture enabling gradual modernization without breaking users.
- **Boundary Discipline:** Clear, minimal FFI boundaries with no Rust-side reimplementation of stable C logic unless explicitly justified.

### Interfaces
- **CLI First:** Stable, scriptable command-line interface as the primary interaction model.

## 5. Non-Goals
- Replacing full media players or editors.
- Providing a graphical UI as a primary interface.
- Automatic translation without explicit user configuration.
- Breaking existing workflows for the sake of internal refactoring.

## 6. Stability Guarantees
- CLI flags remain backward-compatible unless explicitly deprecated.
- Output formats preserve existing semantics.
- Rust components must interoperate cleanly with the C core.
- Deprecations must be documented, versioned, and communicated before removal.

## 7. Contribution Philosophy
Changes must prioritize correctness, determinism, and backward compatibility. Submissions that regress stability, output semantics, or CLI behavior will not be accepted, regardless of internal code quality.
