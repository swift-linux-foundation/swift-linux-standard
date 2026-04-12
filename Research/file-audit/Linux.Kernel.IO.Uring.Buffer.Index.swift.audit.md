# Audit: Linux.Kernel.IO.Uring.Buffer.Index.swift

## Summary

`RawRepresentable` struct over `UInt16` for indexing into registered buffer arrays.

## Findings

| ID | Status | Finding |
|----|--------|---------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Buffer.Index` -- proper Nest.Name |
| [API-NAME-003] | PASS | Maps the `buf_index` field (`__u16`) of `struct io_uring_sqe` |
| [API-IMPL-005] | PASS | Single type + extensions |
| [API-IMPL-008] | PASS | Minimal: rawValue, init, one constant |
| [IMPL-002] | QUESTION | Manual `RawRepresentable` struct with public `rawValue`. Could use `Tagged<Kernel.IO.Uring.Buffer.Index, UInt16>` for consistency with Personality.ID. However, Buffer.Index has `ExpressibleByIntegerLiteral` which may not be available on Tagged. Also, Index is a well-established ecosystem type -- should this use `Index<Kernel.IO.Uring.Buffer>` from index-primitives instead? |
| [IMPL-006] | PASS | `UInt16` matches kernel's `__u16 buf_index` |
| [IMPL-064] | PASS | Value identifier -- Copyable correct |

## Protocol Conformances

- Has: `RawRepresentable`, `Sendable`, `Equatable`, `Hashable`, `ExpressibleByIntegerLiteral`, `CustomStringConvertible`
- Missing: `Comparable` -- buffer indices have a natural ordering (0, 1, 2...). Could be useful for range operations on registered buffers.

## Issues

1. **Could use ecosystem `Index<T>` type**: The primitives layer provides typed index types. `Buffer.Index` could leverage these for Comparable, arithmetic, and other index operations. However, the ecosystem index types may use a different raw type (Int vs UInt16), which would lose the bit-width match to the kernel ABI.

2. **`.first` naming**: `static let first = Index(0)` is good. Missing `static let none` or similar sentinel if the kernel uses any sentinel value for "no buffer index." Verify kernel semantics.

3. **`let` rawValue**: Correct for immutable identifier.

4. **Consistency with Buffer.Group**: Both are `RawRepresentable` over `UInt16` with identical structure. Consider whether a shared pattern (e.g., both using Tagged) would reduce boilerplate.

## Verdict

Clean, functional. Consider whether ecosystem index types or Tagged would be more appropriate than a manual struct.
