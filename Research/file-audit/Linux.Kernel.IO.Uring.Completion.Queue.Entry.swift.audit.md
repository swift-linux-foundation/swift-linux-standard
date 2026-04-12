# Audit: Linux.Kernel.IO.Uring.Completion.Queue.Entry.swift

**Path**: `Sources/Linux Kernel IO Uring Standard/Linux.Kernel.IO.Uring.Completion.Queue.Entry.swift`

## Findings

| ID | Rule | Status | Detail |
|----|------|--------|--------|
| 1 | [API-NAME-001] | Pass | `Kernel.IO.Uring.Completion.Queue.Entry` -- proper nesting |
| 2 | [API-NAME-002] | Pass | `isSuccess`, `isError`, `isCancelled` are standard Swift Boolean naming |
| 3 | [API-IMPL-005] | Pass | Single struct with extensions in same file |
| 4 | [API-IMPL-008] | Pass | Minimal stored property, internal init |
| 5 | [API-ERR-001] | N/A | No throwing functions |
| 6 | [IMPL-INTENT] | Pass | Accessors read clearly |
| 7 | [IMPL-064] | **Resolved: Copyable is correct** | CQEs are kernel-produced read-only values copied from shared memory. No resource to protect, no slot to guard. ~Copyable would add borrowing/consuming friction with zero semantic benefit |
| 8 | [IMPL-COMPILE] | Pass | |
| 9 | Untyped integers | **Finding** | `res` (line 76-78) is public `Int32`. This raw result field encodes either success count or negated errno. `res` should be `internal` with typed public surface only (`isSuccess`/`errorNumber` etc.) |
| 10 | Unnecessary public API | **Finding** | Both `res` (raw Int32) and typed accessors (`isSuccess`/`isError`/`errorNumber`) are public. Callers can bypass the typed API. `res` should be internal |
| 11 | Doc comments | **Finding** | Usage example at line 42 references `entry.result` but actual property is `entry.res`. Doc comment does not match API |
| 12 | Unused imports | **Finding** | `Kernel_Descriptor_Primitives`, `Kernel_File_Primitives` appear unused |
| 13 | `flags` vs `options` | **Finding** | Property is `flags` (line 83) but type is `Options`. Per [feedback_options_not_flags], property should be `options` to match the type name |

## Assessment

Most consequential file. The ~Copyable question is correctly resolved as "no." Key findings: raw `Int32` `res` leaking into public API, stale doc comment referencing nonexistent `result` property, and `flags`/`Options` naming mismatch.
