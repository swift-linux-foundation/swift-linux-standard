# Audit: Linux.Kernel.IO.Uring.Buffer.Group.swift

## Summary

`RawRepresentable` struct over `UInt16` for buffer group identifiers (automatic buffer selection).

## Findings

| ID | Status | Finding |
|----|--------|---------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Buffer.Group` -- proper Nest.Name |
| [API-NAME-003] | PASS | Maps `buf_group` field (`__u16`) of `struct io_uring_sqe`, used with `IOSQE_BUFFER_SELECT` |
| [API-IMPL-005] | PASS | Single type + extensions |
| [API-IMPL-008] | PASS | Minimal: rawValue, init |
| [IMPL-002] | QUESTION | Same as Buffer.Index -- manual `RawRepresentable` where `Tagged<Kernel.IO.Uring.Buffer.Group, UInt16>` would be more consistent with Personality.ID and Operation.Data. |
| [IMPL-006] | PASS | `UInt16` matches kernel's `__u16 buf_group` |
| [IMPL-064] | PASS | Value identifier -- Copyable correct |

## Protocol Conformances

- Has: `RawRepresentable`, `Sendable`, `Equatable`, `Hashable`, `ExpressibleByIntegerLiteral`, `CustomStringConvertible`
- Missing: None critical. `Comparable` could be added but group IDs have no inherent ordering beyond arbitrary user assignment.

## Issues

1. **No common values**: Unlike Buffer.Index (which has `.first`), Group has no predefined constants. This is correct -- group IDs are user-assigned, there is no canonical "first" group.

2. **Structural duplication with Buffer.Index**: Buffer.Group and Buffer.Index are structurally identical (same rawValue type, same conformances, same init pattern). The only difference is semantic (group vs index). This is fine -- they SHOULD be distinct types to prevent mixing them up at the call site.

3. **Could use Tagged**: `typealias Group = Tagged<..., UInt16>` would need a phantom tag. Since Group IS the type (not a tag for something else), manual struct is arguably cleaner than the self-referential Tagged pattern.

4. **Missing doc on `init(_ value: UInt16)`**: Has `init(rawValue:)` documented but `init(_ value:)` has no doc comment. Minor.

## Verdict

Clean, minimal, correct. Consistent with Buffer.Index. The manual-struct-vs-Tagged question applies equally to both Buffer.Index and Buffer.Group.
