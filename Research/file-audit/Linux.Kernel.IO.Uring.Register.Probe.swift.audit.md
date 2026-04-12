# Audit: Linux.Kernel.IO.Uring.Register.Probe.swift

## Summary

Single probe opcode. Same metatype pattern.

## Findings

| Rule | Status | Detail |
|------|--------|--------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Register.Probe` -- proper Nest.Name |
| [API-NAME-002] | PASS | No compound identifiers |
| [API-IMPL-005] | DEFECT | Two type-level declarations in one file (struct Probe + Opcode extension) |
| [API-IMPL-008] | PASS | Minimal body |
| [IMPL-006] | PASS | `Opcode` typed |
| [IMPL-COMPILE] | PASS | |

## Completeness

The probe opcode exists but there is no `Probe.Result` or `Probe.Entry` type to represent the `io_uring_probe` / `io_uring_probe_op` structures that the kernel fills in. At L2, providing the opcode alone is sufficient -- the probe result structures would be needed to make this actually usable. Currently half-complete: you can call the probe syscall but cannot interpret the result in a typed way.

## Doc Comments

Present. Adequate.
