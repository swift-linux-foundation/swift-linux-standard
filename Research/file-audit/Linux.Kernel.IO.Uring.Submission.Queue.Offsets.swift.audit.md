# Audit: Linux.Kernel.IO.Uring.Submission.Queue.Offsets.swift

**Path**: `Sources/Linux Kernel IO Uring Standard/Linux.Kernel.IO.Uring.Submission.Queue.Offsets.swift`

## Findings

| ID | Rule | Status | Detail |
|----|------|--------|--------|
| 1 | [API-NAME-001] | Pass | `Kernel.IO.Uring.Submission.Queue.Offsets` -- proper nesting |
| 2 | [API-NAME-002] | **Finding** | `ringMask` and `ringEntries` are compound identifiers at public scope. Already inside `Queue` -- should be `mask` and `entries`, or nested `.ring.mask` |
| 3 | [API-IMPL-005] | **Finding** | Contains two declarations: `Offsets` struct AND `extension Memory.Address.Offset` with `package init(_ cOffset: UInt32)`. The `Memory.Address.Offset` extension belongs in a separate file or at the primitives layer |
| 4 | [API-IMPL-008] | Pass | Stored properties + two inits |
| 5 | [API-ERR-001] | N/A | No throwing functions |
| 6 | [IMPL-INTENT] | Pass | Property names describe what each offset locates |
| 7 | [IMPL-064] | Pass | Immutable value type; Sendable is correct |
| 8 | [IMPL-COMPILE] | Pass | All offsets typed as `Memory.Address.Offset` |
| 9 | Untyped integers | Pass | All fields are `Memory.Address.Offset`, not raw integers |
| 10 | Unnecessary public API | Pass | All offsets needed for mmap setup |
| 11 | Doc comments | Pass | Struct and all properties documented |
| 12 | Cross-layer concern | **Finding** | The `Memory.Address.Offset` extension at lines 81-87 extends an L1 type with a `package` init inside an L2 file. If this conversion is needed in multiple places, it should live closer to the primitives layer |

## Assessment

Good offset modeling with `Memory.Address.Offset`. Three findings: compound `ringMask`/`ringEntries`, cross-type extension violating one-type-per-file, and cross-layer conversion init at wrong level.
