# Audit: Linux.Kernel.IO.Uring.Priority.swift

## Summary

`RawRepresentable` struct over `UInt16` for `ioprio` field in SQE.

## Findings

| ID | Status | Finding |
|----|--------|---------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Priority` -- proper Nest.Name |
| [API-NAME-003] | PASS | Maps `ioprio` field from `struct io_uring_sqe` (`__u16`) |
| [API-IMPL-005] | PASS | Single type + extensions |
| [API-IMPL-008] | PASS | Minimal body: rawValue, init, two constants |
| [IMPL-002] | QUESTION | Manual `RawRepresentable` struct with public `rawValue`. This type could use `Tagged<Kernel.IO.Uring.Priority, UInt16>` for consistency with `Personality.ID` and `Operation.Data`. However, Priority has `Comparable` and `ExpressibleByIntegerLiteral` which Tagged may not provide out of the box, so manual struct may be justified. |
| [IMPL-006] | PASS | `UInt16` matches kernel's `__u16 ioprio` |
| [IMPL-064] | PASS | Value type -- Copyable correct |

## Protocol Conformances

- Has: `RawRepresentable`, `Sendable`, `Equatable`, `Hashable`, `Comparable`, `ExpressibleByIntegerLiteral`, `CustomStringConvertible`
- Complete for this type.

## Issues

1. **`default` and `normal` are identical**: Both are `Priority(0)`. This is semantically correct (zero means "no priority set" which is the default best-effort), but having two names for the same value is confusing. Recommend removing one, or documenting that they are aliases.

2. **Missing priority class/level accessors**: The doc comment describes bits 13-15 as priority class and bits 0-12 as priority level, but there are no accessors to extract or construct these. For a "theoretically perfect" implementation:
   ```swift
   var priorityClass: UInt8 { UInt8(rawValue >> 13) }
   var level: UInt16 { rawValue & 0x1FFF }
   static func bestEffort(level: UInt16) -> Priority { ... }
   static func realtime(level: UInt16) -> Priority { ... }
   static func idle() -> Priority { ... }
   ```
   These would mirror `IOPRIO_CLASS_*` and `IOPRIO_PRIO_VALUE()` from `<linux/ioprio.h>`.

3. **Could use Dimension infrastructure**: Priority could be modeled as `Magnitude<Kernel.IO.Uring.Priority>.Value<UInt16>` for consistency with Length. However, priorities have bitfield structure (class + level), not simple magnitude semantics, so manual struct is arguably more appropriate.

4. **`let` rawValue**: Correct for immutable identifier.

## Verdict

Functional but incomplete. The type documents priority class/level semantics but does not expose them. The `default`/`normal` duplication should be resolved.
