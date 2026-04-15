# Audit: Linux.Kernel.IO.Uring.Mmap.Offset.swift

## Summary

Magic mmap offset constants for io_uring ring buffer mapping.

## Findings

| Rule | Status | Detail |
|------|--------|--------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Mmap.Offset` -- proper Nest.Name |
| [API-NAME-002] | OBSERVATION | `.sqRing`, `.cqRing` are compound abbreviations. Spec-mirroring (`IORING_OFF_SQ_RING`, `IORING_OFF_CQ_RING`). |
| [API-IMPL-005] | PASS | Single type declaration (`enum Offset`) |
| [API-IMPL-008] | PASS | Three static constants only |
| [IMPL-002] | DEFECT | Constants are typed as bare `Int64`. These should use `Memory.Address.Offset` or a dedicated typed wrapper to prevent accidental arithmetic with unrelated integers. |
| [IMPL-006] | DEFECT | Same as IMPL-002: `Int64` raw type instead of `Memory.Address.Offset` |
| [IMPL-COMPILE] | OBSERVATION | Bare `Int64` allows mixing with unrelated integer values |

## Correctness

Values are correct:
- `sqRing = 0` matches `IORING_OFF_SQ_RING`
- `cqRing = 0x8000000` matches `IORING_OFF_CQ_RING`
- `sqes = 0x1000_0000` matches `IORING_OFF_SQES`

The `cqRing` constant in the doc comment and value match (`0x8000000`). The `sqes` value uses underscore grouping (`0x1000_0000`) while `cqRing` does not (`0x8000000`) -- minor formatting inconsistency.

## Design Observation

These offsets are consumed by `mmap()` which takes `off_t` (Int/Int64). The `Mmap.Offset` enum acts as a namespace for raw constants passed directly to a C function. At L2, raw `Int64` for mmap offsets is defensible since these are magic constants for a C syscall parameter. However, `Memory.Address.Offset` would be more consistent with how `Submission.Queue.Offsets` and `Completion.Queue.Offsets` handle their offsets.

## Doc Comments

Present and thorough with usage example showing mmap integration.
