# Audit: Linux.Kernel.IO.Uring.Poll.Options.swift

## Findings

| # | Rule | Severity | Finding |
|---|------|----------|---------|
| 1 | [API-IMPL-005] | **Major** | File contains two types: `Kernel.IO.Uring.Poll.Options` (OptionSet, lines 27-43) and a `Kernel.IO.Uring.Poll.Trigger` extension with `var option` (lines 46-55). The Trigger extension belongs in `Poll.Trigger.swift`, not here. |
| 2 | Completeness | **Minor** | `IORING_POLL_UPDATE_EVENTS` and `IORING_POLL_UPDATE_USER_DATA` flags from io_uring.h are absent. These are used with `IORING_OP_POLL_REMOVE` to update an existing poll request. Consider adding if poll update is intended to be supported. |
| 3 | [API-NAME-001] | Pass | `Kernel.IO.Uring.Poll.Options` follows Nest.Name. |
| 4 | [API-NAME-003] | Pass | Uses `IORING_POLL_ADD_LEVEL` and `IORING_POLL_ADD_MULTI` from kernel header. |
| 5 | [IMPL-002] | Pass | `rawValue` on OptionSet is the standard Swift pattern. |
