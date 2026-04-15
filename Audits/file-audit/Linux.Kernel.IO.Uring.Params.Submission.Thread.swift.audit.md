# Audit: Linux.Kernel.IO.Uring.Params.Submission.Thread.swift

## Summary

Thread configuration for SQ polling: CPU affinity and idle timeout. Uses typed properties (`System.Processor.ID`, `Duration`). C boundary conversion is clean.

## Findings

| Rule | Status | Detail |
|------|--------|--------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Params.Submission.Thread` -- proper Nest.Name |
| [API-NAME-002] | PASS | No compound identifiers |
| [API-IMPL-005] | PASS | Single type declaration (`Thread`) plus C boundary extension |
| [API-IMPL-008] | PASS | Two stored properties + init |
| [IMPL-002] | PASS | No raw integers in public API: `System.Processor.ID` and `Duration` |
| [IMPL-006] | PASS | Fully typed stored properties |
| [IMPL-COMPILE] | PASS | |
| [IMPL-INTENT] | PASS | `thread.cpu` and `thread.idle` read as intent |

## C Boundary Analysis

### `cCpu` (line 53-55)
```swift
internal var cCpu: UInt32 {
    UInt32(cpu.rawValue.rawValue)
}
```
Double `.rawValue` unwrap: `System.Processor.ID` -> `Ordinal` -> `UInt`. This is the correct pattern for L2 C boundary code -- rawValue access is confined to internal conversion.

### `cIdle` (line 58-62)
```swift
let (seconds, attoseconds) = idle.components
let ms = seconds * 1000 + attoseconds / 1_000_000_000_000_000
return UInt32(clamping: ms)
```
Converts `Duration` to milliseconds for the kernel. Uses `clamping:` to prevent overflow. Correct.

### `init(cCpu:cIdle:)` (line 47-50)
```swift
self.cpu = System.Processor.ID(__unchecked: (), Ordinal(UInt(cCpu)))
self.idle = .milliseconds(Int(cIdle))
```
Clean typed construction from C values.

## Doc Comments

All public members documented with parameter descriptions. Good.
