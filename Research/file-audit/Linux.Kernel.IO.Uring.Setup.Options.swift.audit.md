# Audit: Linux.Kernel.IO.Uring.Setup.Options.swift

## Summary

OptionSet wrapping `IORING_SETUP_*` flags. Well-documented, correct bit values.

## Findings

| Rule | Status | Detail |
|------|--------|--------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Setup.Options` -- proper Nest.Name |
| [API-NAME-002] | OBSERVATION | `.sqPoll`, `.sqAff`, `.coopTaskrun`, `.taskrunFlag`, `.deferTaskrun` are compound names. However, these mirror Linux kernel spec constants (`IORING_SETUP_SQPOLL`, etc.), so [API-NAME-003] applies. Acceptable. |
| [API-IMPL-005] | PASS | Single type declaration (`Options`) plus static members in separate extension |
| [API-IMPL-008] | PASS | Minimal body: `rawValue` + `init` only |
| [API-ERR-001] | N/A | No throwing functions |
| [IMPL-002] | PASS | `rawValue: UInt32` public via `OptionSet` protocol -- standard pattern |
| [IMPL-006] | PASS | `UInt32` via OptionSet |
| [IMPL-COMPILE] | PASS | OptionSet provides type safety |

## Defects

### D1: `.submitAll` doc comment is wrong (line 134)

Doc says "Allows the kernel to choose the SQ thread CPU." This describes something else entirely. `IORING_SETUP_SUBMIT_ALL` (bit 7) means: continue submitting remaining SQEs even if one SQE encounters an error, rather than stopping at the first failure. The current doc describes behavior related to `.sqAff`.

### D2: `.taskrunFlag` name is misleading (line 149)

The Linux constant is `IORING_SETUP_TASKRUN_FLAG`. The doc says "Enables single-issuer task running mode" but that is `.singleIssuer`. `TASKRUN_FLAG` enables a flag in the SQ ring flags field that signals when task work is pending, so userspace can check the flag instead of always entering the kernel. The name `.taskrunFlag` is spec-faithful but the doc comment is incorrect.

## Missing Constants

- `IORING_SETUP_NO_MMAP` (1 << 14, kernel 6.5+)
- `IORING_SETUP_REGISTERED_FD_ONLY` (1 << 15, kernel 6.5+)
- `IORING_SETUP_NO_SQARRAY` (1 << 16, kernel 6.6+)

Not blocking but worth adding for completeness.

## Doc Comments

Present on all members. Kernel version table is excellent. Two doc comments have incorrect descriptions (D1, D2 above).
