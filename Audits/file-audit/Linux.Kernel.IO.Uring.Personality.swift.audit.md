# Audit: Linux.Kernel.IO.Uring.Personality.swift

## Summary

`enum Personality {}` namespace with `typealias ID = Tagged<..., UInt16>`.

## Findings

| ID | Status | Finding |
|----|--------|---------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Personality` (namespace) and `Kernel.IO.Uring.Personality.ID` -- proper Nest.Name |
| [API-NAME-003] | PASS | Maps `personality` field (`__u16`) of `struct io_uring_sqe` and `IORING_REGISTER_PERSONALITY` |
| [API-IMPL-005] | VIOLATION | File contains `enum Personality` (namespace), `typealias ID`, AND `extension Tagged where Tag == ...`. Three logical declarations. The namespace and typealias could arguably share a file, but the `extension Tagged` is a separate concern. |
| [API-IMPL-008] | PASS | Namespace is empty; ID is a typealias |
| [IMPL-002] | PASS | Uses Tagged -- rawValue access is controlled |
| [IMPL-006] | PASS | `UInt16` matches kernel's `__u16 personality` |
| [IMPL-064] | PASS | Value identifier -- Copyable correct |

## Protocol Conformances

Inherited from Tagged: `Equatable`, `Hashable`, `Sendable`, `RawRepresentable`.

- Missing: `CustomStringConvertible` -- minor, useful for debugging.
- Missing: `ExpressibleByIntegerLiteral` -- personality IDs are kernel-assigned, so integer literal construction is not meaningful. Correct to omit.

## Issues

1. **`extension Tagged where Tag == ...` pattern**: The `.none` constant is defined on a constrained extension of `Tagged` rather than on `Kernel.IO.Uring.Personality.ID`. This is because `ID` is a typealias, not a distinct type, so `extension Kernel.IO.Uring.Personality.ID` may not work in all Swift versions for adding static members. The workaround is correct but is a known Swift limitation. Verify whether `extension Kernel.IO.Uring.Personality.ID` would work on the target Swift 6.3+ toolchain.

2. **`var` vs `let` for `.none`**: `.none` is a computed property (`var ... { Self(...) }`), not a stored `static let`. This means it creates a new instance each call. For a zero-cost type this is fine, but `static let` would be more consistent with how `.zero` is defined on `Operation.Data`.

3. **Namespace depth**: `Kernel.IO.Uring.Personality.ID` is 5 levels deep. This is necessary -- Personality is a meaningful grouping if more types are planned (e.g., `Personality.Credentials`).

## Verdict

Well-modeled. The `extension Tagged` pattern is a pragmatic workaround. The `var` vs `let` inconsistency with Operation.Data's `.zero` is minor.
