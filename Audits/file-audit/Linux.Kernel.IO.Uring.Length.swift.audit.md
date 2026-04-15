# Audit: Linux.Kernel.IO.Uring.Length.swift

## Summary

`typealias Length = Magnitude<Space>.Value<UInt32>` -- byte length for io_uring operations.

## Findings

| ID | Status | Finding |
|----|--------|---------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Length` -- proper Nest.Name |
| [API-NAME-003] | PASS | Maps the `len` field (`__u32`) of `struct io_uring_sqe` |
| [API-IMPL-005] | PASS | Single typealias + extensions |
| [API-IMPL-008] | PASS | Typealias to Dimension infrastructure; extensions add only conversions |
| [IMPL-002] | PASS | Uses Dimension infrastructure (Magnitude) -- not raw integer |
| [IMPL-006] | PASS | `UInt32` matches kernel's `__u32 len` |
| [IMPL-064] | PASS | Value type -- Copyable correct |

## Protocol Conformances

Inherited from `Magnitude<Space>.Value<UInt32>`: should include `Equatable`, `Hashable`, `Comparable`, `Sendable`.

- Verify: Does Magnitude.Value provide `ExpressibleByIntegerLiteral`? The doc example uses `let length: Kernel.IO.Uring.Length = 4096` which requires it.
- Missing: `CustomStringConvertible` -- would be useful for debugging. Minor.

## Issues

1. **Clamping semantics are silent**: `init(_ count: Int)` clamps silently. For a 4GB+ buffer this silently truncates to `UInt32.max`. At L2 this is acceptable (the kernel ABI physically cannot accept more than 32 bits), but a `precondition` or `init?(exactly:)` alternative would be more explicit about the truncation.

2. **File.Size conversion is thorough**: The `init(_ size: Kernel.File.Size)` handles negative values (maps to 0) and overflow (saturates at max). Good defensive coding.

3. **Span inits are forward-looking**: `init(_ span: Span<UInt8>)` and `init(_ span: borrowing MutableSpan<UInt8>)` use Swift 6 safe buffer types. Good.

4. **Import breadth**: Imports `Binary_Primitives_Core` plus 4 kernel primitives modules. `Kernel_Descriptor_Primitives`, `Kernel_Error_Primitives`, `Kernel_Memory_Primitives` may be unnecessary for this file. Verify whether these are needed for transitive type resolution.

## Verdict

Excellent use of Dimension infrastructure. Clamping-vs-trapping tradeoff is the only design question.
