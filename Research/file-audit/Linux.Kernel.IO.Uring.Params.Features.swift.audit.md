# Audit: Linux.Kernel.IO.Uring.Params.Features.swift

## Summary

Kernel-reported feature flags. NOT an OptionSet -- uses manual `contains()`. All 14 flags present.

## Findings

| Rule | Status | Detail |
|------|--------|--------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Params.Features` -- proper Nest.Name |
| [API-NAME-002] | OBSERVATION | `.singleMmap`, `.rwCurrentPosition`, `.currentPersonality`, `.fastPoll`, `.poll32Bits`, `.sqPollNonFixed`, `.nativeWorkers`, `.resourceTags`, `.cqeSkip`, `.linkedFile`, `.regRegRing` -- compound names with spec justification. |
| [API-IMPL-005] | PASS | Single type declaration (`Features`) plus extensions for constants and query |
| [API-IMPL-008] | PASS | Minimal body: `rawValue` + `init` |
| [IMPL-002] | PASS | `rawValue: UInt32` public -- standard for bitflag types |
| [IMPL-006] | PASS | `UInt32` |
| [IMPL-COMPILE] | OBSERVATION | See below |

## Design Observation: Not OptionSet

`Features` is NOT conforming to `OptionSet`. It has:
- `rawValue: UInt32` + `init(rawValue:)`
- Manual `contains(_:)` method

This is deliberate and correct: features are kernel-reported (read-only from the application's perspective), so OptionSet's `insert`/`remove`/`union` etc. would be misleading API surface. The manual `contains()` is exactly right -- you query what the kernel supports, you do not compose feature sets.

However, `Features` could conform to `OptionSet` with `private(set)` enforcement at the `Params` level (which it already has). The OptionSet conformance would give `SetAlgebra` membership testing for free without implying mutability. This is a judgment call, not a defect.

## Missing Features

- `IORING_FEAT_RECVSEND_BUNDLE` (1 << 14, kernel 6.10+)

## Doc Comments

All members documented. Type-level doc correctly states these are kernel-filled.

## Correctness

The `@inlinable` on `init(rawValue:)` and `contains(_:)` is appropriate -- these are trivial operations that benefit from inlining.
