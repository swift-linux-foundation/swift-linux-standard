# Audit: Linux.Kernel.IO.Uring.Install.Options.swift

## Findings

| # | Rule | Severity | Finding |
|---|------|----------|---------|
| 1 | [API-IMPL-005] | **Major** | File contains two types: `Kernel.IO.Uring.Fixed.Install` (struct, line 23) and `Kernel.IO.Uring.Fixed.Install.Options` (OptionSet, line 24). The `Install` namespace should be in its own file `Linux.Kernel.IO.Uring.Fixed.Install.swift`. |
| 2 | [API-NAME-002] | **Minor** | `noCloseOnExec` (line 33) is a compound identifier. Consider decomposing or using the kernel-mirroring name pattern. The kernel constant is `IORING_FIXED_FD_NO_CLOEXEC`. |
| 3 | Filename | **Minor** | File is named `Linux.Kernel.IO.Uring.Install.Options.swift` but the type path is `Kernel.IO.Uring.Fixed.Install.Options`. The filename omits `Fixed` from the path. Should be `Linux.Kernel.IO.Uring.Fixed.Install.Options.swift`. |
| 4 | [API-NAME-001] | Pass | `Kernel.IO.Uring.Fixed.Install.Options` follows Nest.Name. |
| 5 | [API-NAME-003] | Pass | Uses `IORING_FIXED_FD_NO_CLOEXEC` from kernel header. Correct. |
