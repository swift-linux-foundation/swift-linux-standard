# Audit: Linux.Kernel.IO.Uring.Wait.Options.swift

## Findings

| # | Rule | Severity | Finding |
|---|------|----------|---------|
| 1 | Design | **Minor** | The OptionSet currently has only `.none` (empty set). This is a placeholder. The type exists for forward-compatibility, which is reasonable, but the doc comment "Reserved for kernel use" is inaccurate -- the flags field is for userspace to configure the waitid call. The kernel may define flags in the future, or waitid-specific flags from `<sys/wait.h>` (`WNOHANG`, `WEXITED`, `WSTOPPED`, `WCONTINUED`, etc.) may be relevant here. |
| 2 | [API-IMPL-005] | Pass | Single type `Kernel.IO.Uring.Wait.Options` per file. |
| 3 | [API-NAME-001] | Pass | `Kernel.IO.Uring.Wait.Options` follows Nest.Name. |
