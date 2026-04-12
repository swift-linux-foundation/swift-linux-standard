# Audit: Linux.Kernel.IO.Uring.Offset.swift

## Summary

`typealias Offset = Coordinate.X<Space>.Value<UInt64>` -- file position for io_uring operations.

## Findings

| ID | Status | Finding |
|----|--------|---------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Offset` -- proper Nest.Name |
| [API-NAME-003] | PASS | Maps the `off` field (`__u64`) of `struct io_uring_sqe`. Sentinel `UInt64.max` == "current position" matches kernel semantics (`(__u64)-1`). |
| [API-IMPL-005] | PASS | Single typealias + extensions |
| [API-IMPL-008] | PASS | Typealias to Dimension infrastructure; extensions add `.zero`, `.current`, cross-space conversion |
| [IMPL-002] | PASS | Uses Dimension infrastructure (Coordinate) -- not raw integer |
| [IMPL-006] | PASS | `UInt64` matches kernel's `__u64 off` |
| [IMPL-064] | PASS | Value type -- Copyable correct |

## Protocol Conformances

Inherited from `Coordinate.X<Space>.Value<UInt64>`: should include `Equatable`, `Hashable`, `Comparable`, `Sendable`.

- Has: `CustomStringConvertible` (explicitly provided)
- Verify: Does the Coordinate base provide `Comparable`? File offsets have a natural order.

## Issues

1. **`.current` sentinel**: `UInt64.max` as sentinel for "current position" is correct per the kernel ABI. The `CustomStringConvertible` implementation handles it (`"current"`). Good.

2. **Cross-space conversion is correct**: `init(_ fileOffset: Kernel.File.Offset)` maps negative offsets to `.current` and non-negative to direct value. This matches the kernel convention where `off_t(-1)` means "use current position" and io_uring uses `UInt64.max` for the same.

3. **Import redundancy**: Imports `Dimension_Primitives` (for Coordinate) AND `Binary_Primitives_Core`. Verify whether both are needed or if one re-exports the other. Also imports 4 kernel primitives modules, some of which may be unnecessary.

4. **Missing: `init(_ value: UInt64)` convenience**: Unlike Length which has `init(_ count: Int)`, Offset has no convenience init from an integer. Users must go through the Dimension init. Minor -- the cross-space init from `File.Offset` covers the main use case.

## Verdict

Excellent. Clean use of Coordinate infrastructure with proper sentinel handling.
