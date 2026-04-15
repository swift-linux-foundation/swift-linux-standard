# Audit: Linux.Kernel.IO.Uring.swift

**File**: `/Users/coen/Developer/swift-linux-foundation/swift-linux-standard/Sources/Linux Kernel IO Uring Standard/Linux.Kernel.IO.Uring.swift`
**Lines**: 567

## Findings

| # | Severity | Rule | Line(s) | Finding |
|---|----------|------|---------|---------|
| 1 | Pass | API-NAME-001 | 55 | `Kernel.IO.Uring` uses Nest.Name correctly. |
| 2 | Pass | API-NAME-002 | all | No compound method/property names. `hasCapacity`, `completionsAvailable` are single-concept properties. |
| 3 | Pass | API-IMPL-005 | entire | Single type (`Kernel.IO.Uring`) declared. All other content is extensions on that type. |
| 4 | Info | API-IMPL-008 | 55-139 | Struct body contains stored properties, canonical init, AND `deinit`. The deinit is required for ~Copyable resource cleanup and cannot live in an extension. Compliant. |
| 5 | Pass | API-ERR-001 | 183, 219, 260, 308 | All throwing functions use typed throws: `throws(Kernel.IO.Uring.Error)` or `throws(Error)`. |
| 6 | Pass | IMPL-INTENT | all | Code reads as intent. WHY comments at lines 417-419 explain the `.vector.rawValue` extraction. MARK sections organize by domain. |
| 7 | Minor | IMPL-002 | 185 | `entries.rawValue.rawValue` -- double `.rawValue` extraction at line 185 (`UInt32(entries.rawValue.rawValue)`). The `Cardinal` wrapping creates two layers. Also at lines 233, 482, 514, 519. This is a systematic boundary-crossing cost; acceptable since it happens at the syscall boundary only. |
| 8 | Pass | IMPL-064 | 55 | `Uring: ~Copyable` -- correct ownership posture. |
| 9 | Pass | IMPL-065 | 462-468 | `next` property yields `Slot` (which is ~Escapable) via `_read` coroutine -- scoped access enforced. |
| 10 | Pass | IMPL-067 | 96, 112, 215, 287 | `consuming` on descriptor parameters, `borrowing` on fd parameters in static methods. Explicit ownership throughout. |
| 11 | Pass | IMPL-071 | N/A | No interior-mutability pattern needed here; the ring itself is mutated. |
| 12 | Pass | IMPL-COMPILE | 55, 462-468 | ~Copyable prevents aliasing; ~Escapable Slot prevents escaping shared memory references. Target enum enforces fd/flag agreement. |
| 13 | Minor | Unnecessary API | 287-289 | `close(_ fd: consuming Kernel.Descriptor)` swallows errors via `try?`. The deinit already handles cleanup. This static method duplicates what deinit does without the mmap cleanup. Could confuse callers into thinking they can close the fd separately -- the ring's deinit would then operate on a closed fd. Consider removing or making internal. |
| 14 | Pass | Doc comments | all | All public APIs have doc comments with parameter documentation, usage examples, and blocking/cancellation notes. |
| 15 | Info | Unsafe ops | 131-138, 421-438 | `deinit` and factory `init` contain `unsafe` mmap/munmap calls. These are irreducible -- the mmap boundary is inherently unsafe. Factory init validates results before constructing. |
| 16 | Minor | Precise modeling | 79-80 | `sqeHead` and `sqeTail` are `UInt32`. These could be wrapped in a phantom-tagged type (e.g., `Index<Submission.Queue>`) for type-safety. Low priority since they are internal bookkeeping. |
| 17 | Info | Precise modeling | 374 | `sqEntryCount` computed as `Int(bitPattern: params.sqEntries)` -- the `bitPattern` label suggests potential semantic mismatch between `Submission.Count` (unsigned cardinal) and `Int`. This works because ring sizes are always well within Int range, but the conversion could be more explicit. |
| 18 | Minor | Unused import | 158 | `public import CPU_Primitives` is in the second `#if os(Linux)` block. Verify this is needed outside the file -- if only used internally for `CPU.Atomic`, it should be `internal import`. However, consumers may need `CPU.Atomic` for their own fence operations. |

## Assessment

High quality. The ring struct demonstrates excellent ownership modeling: ~Copyable prevents aliasing, the Slot coroutine provides safe scoped access to shared memory, and typed throws are used throughout. The factory init has careful cleanup-on-partial-failure semantics.

Two concerns worth tracking:
1. The static `close` method is a footgun -- it could close the fd while the ring still holds it.
2. The double `.rawValue.rawValue` extractions are ugly but constrained to the syscall boundary.
