# Audit: Linux.Kernel.IO.Uring.Enter.Options.swift

## Summary

OptionSet wrapping `IORING_ENTER_*` flags. Correct values, well-documented.

## Findings

| Rule | Status | Detail |
|------|--------|--------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Enter.Options` -- proper Nest.Name |
| [API-NAME-002] | OBSERVATION | `.getEvents`, `.sqWakeup`, `.sqWait`, `.extArg`, `.registeredRing` -- compound names with spec justification ([API-NAME-003]) |
| [API-IMPL-005] | DEFECT | Static option members are declared INSIDE the struct body (lines 63-95) rather than in a separate extension. Compare with `Setup.Options` which correctly separates struct body from static members. |
| [API-IMPL-008] | PASS | Minimal body |
| [API-ERR-001] | N/A | No throwing functions |
| [IMPL-002] | PASS | `rawValue` public via OptionSet -- acceptable |
| [IMPL-006] | PASS | `UInt32` via OptionSet |
| [IMPL-COMPILE] | PASS | OptionSet type safety |

## Structural Inconsistency

`Setup.Options` declares the struct in one extension and defines static members in a *separate* extension. `Enter.Options` puts everything in a single extension block. Both approaches work but the inconsistency should be resolved -- prefer the `Setup.Options` pattern (separate extension for static members).

## Missing Constants

- `IORING_ENTER_ABS_TIMER` (1 << 5, kernel 6.4+) -- missing.

## Doc Comments

All present and accurate.
