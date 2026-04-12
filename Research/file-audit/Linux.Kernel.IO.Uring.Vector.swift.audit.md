# Audit: Linux.Kernel.IO.Uring.Vector.swift

## Summary

Typed wrapper around `struct iovec` for scatter/gather I/O.

## Findings

| ID | Status | Finding |
|----|--------|---------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Vector` -- proper Nest.Name |
| [API-NAME-003] | PASS | Maps `struct iovec` from `<sys/uio.h>` used in vectored io_uring operations |
| [API-IMPL-005] | PASS | Single type + extensions |
| [API-IMPL-008] | QUESTION | Two stored properties (`base`, `length`) plus multiple inits. Minimal for the domain, but see issues below. |
| [IMPL-002] | CONCERN | `base` and `length` are public `var` with raw pointer/Int types. This is a typed wrapper but the stored properties are untyped raw values. The `length` could be `Kernel.IO.Uring.Length` for type safety, but this would lose the fact that iovec lengths are `Int` (size_t), not `UInt32`. The mismatch is inherent -- iovec uses `size_t` while SQE `len` uses `__u32`. |
| [IMPL-006] | CONCERN | `length: Int` matches `iov_len` (which is `size_t`), but `base: UnsafeMutableRawPointer?` is a raw pointer. Both are dictated by the C ABI. |
| [IMPL-064] | QUESTION | Vector holds a raw pointer and is `@unchecked Sendable`. It does NOT own the pointed-to memory -- it is a non-owning view descriptor. ~Copyable would be wrong here because multiple SQEs may reference the same vector array. However, the `@unchecked Sendable` is a smell -- the pointer it holds may not be safe to send across isolation boundaries. This is inherent to the iovec pattern. |

## Protocol Conformances

- Has: `@unchecked Sendable`
- Missing: `Equatable` -- two Vectors with the same base+length should be equal. Useful for testing.
- Missing: `CustomStringConvertible` -- useful for debugging (`"Vector(base: 0x..., length: 4096)"`).

## Issues

1. **`@unchecked Sendable` justification**: The doc should explain WHY this is `@unchecked Sendable`. The pointer does not confer ownership, and the caller is responsible for lifetime management. A brief `// SAFETY:` comment on the conformance would be appropriate.

2. **Glibc/Musl import**: Uses `#if canImport(Glibc)` / `#if canImport(Musl)` for `iovec`. This is correct for L2 (directly interfacing with kernel ABI). However, `iovec` should also be available through the linux-specific headers without Glibc/Musl if using a C module map.

3. **C bridge is `internal`**: `var cValue: iovec` and `init(_ cValue: iovec)` are internal. Correct -- C types should not leak into public API.

4. **`init(_ buffer: UnsafeRawBufferPointer)` mutating cast**: The comment explains the cast (`UnsafeMutableRawPointer(mutating:)`) is for ABI compatibility -- the kernel does not write to vectors used in write operations. The `@unsafe` annotation is present. Good.

5. **Missing Span-based inits**: Length.swift has `init(_ span: Span<UInt8>)` and `init(_ span: borrowing MutableSpan<UInt8>)`. Vector should also offer Span-based construction for consistency with the safe buffer API direction:
   ```swift
   public init(_ span: Span<UInt8>) { ... }
   public init(_ span: borrowing MutableSpan<UInt8>) { ... }
   ```

## Verdict

Structurally sound for a C ABI bridge type. Missing Equatable. Missing Span-based inits for consistency with Length. The `@unchecked Sendable` needs a safety comment.
