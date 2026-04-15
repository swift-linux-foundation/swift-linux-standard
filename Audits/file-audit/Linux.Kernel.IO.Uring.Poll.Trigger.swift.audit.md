# Audit: Linux.Kernel.IO.Uring.Poll.Trigger.swift

## Findings

| # | Rule | Severity | Finding |
|---|------|----------|---------|
| 1 | Duplication | **Minor** | `pollBits` property (line 43) duplicates the logic already present in `Poll.Options.swift`'s `Trigger.option` computed property (lines 46-55). Two separate conversions from Trigger to raw bits exist: `pollBits` returns `UInt32`, `option` returns `Poll.Options`. Pick one canonical path. |
| 2 | [API-IMPL-005] | Pass | Single type `Kernel.IO.Uring.Poll.Trigger` per file (plus its own extension). |
| 3 | [API-NAME-001] | Pass | `Kernel.IO.Uring.Poll.Trigger` follows Nest.Name. |
| 4 | [API-NAME-003] | Pass | Uses `IORING_POLL_ADD_LEVEL` from kernel header. |
