# Audit: Linux.Kernel.IO.Uring.Submission.Queue.Entry+Prepare.swift

**File**: `/Users/coen/Developer/swift-linux-foundation/swift-linux-standard/Sources/Linux Kernel IO Uring Standard/Linux.Kernel.IO.Uring.Submission.Queue.Entry+Prepare.swift`
**Lines**: 1663 (65 methods)

## Approach

Pattern audit across the full file. Spot-checked 6 representative methods in detail: `nop` (simplest), `read` (core I/O), `openat` (file system), `socket` (networking), `timeout(after:)` (timing), `futex(wait:)` (kernel 6.7+). Then scanned all 65 for systematic issues.

## Systematic Patterns

**Consistent positive patterns across all 65 methods:**
- Every method starts with `self = .init()` -- zeroes the SQE before configuration. Prevents field leakage from previous use.
- Every method sets `self.data = data` as the last statement -- consistent ordering.
- `target.apply(to: &self)` used consistently for fd/flag agreement (Target enum enforces IOSQE_FIXED_FILE).
- `@inlinable` on all methods -- enables cross-module specialization.
- `@unsafe` correctly applied only to methods taking pointer parameters. Non-pointer methods (nop, close, cancel, shutdown, listen, poll, message, etc.) omit it.
- `borrowing` on all `target:` and `source:` descriptor parameters.
- `mutating` on all methods -- correct since they write through `self`.

## Findings

| # | Severity | Rule | Line(s) | Finding |
|---|----------|------|---------|---------|
| 1 | Pass | API-NAME-001 | N/A | No type declarations in this file. Extension-only. |
| 2 | Pass | API-NAME-002 | all | Method names are single-concept verbs overloaded by parameter signature: `read(target:buffer:...)`, `read(target:vectors:...)`, `read(target:length:offset:bufferGroup:...)`. Overloading disambiguates vectored/fixed/multishot variants. |
| 3 | Pass | API-IMPL-005 | entire | No type declarations. Extension methods only. |
| 4 | Pass | API-ERR-001 | N/A | No throwing functions. All methods configure the SQE; errors surface at enter() time. |
| 5 | Pass | IMPL-INTENT | all | Method names mirror io_uring op names (`read`, `write`, `accept`, `connect`, `splice`, `tee`, `poll`, `timeout`, `futex`). Parameter names mirror kernel concepts. WHY comments where field usage is non-obvious (e.g., lines 516-518, 755-756). |
| 6 | Pass | IMPL-002 | all | No `.rawValue` at call sites. All raw value injection happens through the typed internal accessors in Entry.swift. |
| 7 | Pass | IMPL-064 | N/A | Extension on ~Copyable Entry. |
| 8 | Pass | IMPL-067 | all | `borrowing` on Target/Descriptor parameters. `mutating` on all methods. |
| 9 | Pass | IMPL-COMPILE | all | Target enum + typed accessors ensure compile-time correctness of SQE field/flag combinations. |
| 10 | Minor | Precise modeling | 510, 750 | `ftruncate` parameter `length: Kernel.IO.Uring.Offset` -- semantically a length, typed as an offset. The WHY comment at 516-518 explains this is because both map to the same SQE field, but a `Length` or `File.Size` type would be more precise. |
| 11 | Minor | Precise modeling | 625, 717 | `renameat` and `linkat` take `newDirFd: Int32` -- a raw Int32 for a directory file descriptor. Should be `Kernel.Descriptor` or `Kernel.IO.Uring.Target` for type safety. |
| 12 | Minor | Precise modeling | 674 | `mkdirat` takes `mode: UInt32` -- raw integer for permissions. The Entry.swift file already has a `filePermissions` accessor for `Kernel.File.Permissions`. Should use that type here. |
| 13 | Minor | Precise modeling | 898 | `zeroCopyFlags: Kernel.IO.Uring.Priority` -- the parameter name says "flags" but the type is `Priority`. This is because the ioprio field is overloaded for zero-copy flags. The parameter name is misleading; either rename to `priority` or create a dedicated `ZeroCopy.Options` type. |
| 14 | Minor | Precise modeling | 1191, 1319 | `message(ring fd: Int32, ...)` and `install(fd: UInt32, ...)` use raw integer fd values. These could be `Kernel.Descriptor` or dedicated index types. |
| 15 | Pass | Doc comments | all | Every public method has a doc comment with all parameters documented. |
| 16 | Pass | Unsafe ops | all | `@unsafe` is consistently applied to all and only methods that take pointer parameters. Methods without pointers (`nop`, `cancel`, `close`, `listen`, `shutdown`, `poll(remove:)`, `timeout(remove:)`, `message`, `remove(bufferCount:)`, `install`, `nop128`, `command`, `socket`) correctly omit it. |
| 17 | Info | Design | all | The `self = .init()` pattern zeros all 64 bytes of the SQE on every configuration call. This is correct for safety (no field leakage) but has a measurable cost. An alternative would be a factory method that returns a new Entry, but the current pattern enables in-place mutation through the Slot's `nonmutating _modify`, which is the right trade-off. |
| 18 | Info | Import | 25 | `Linux_Kernel_System_Standard` is imported here but not in Entry.swift. This is for `Kernel.Signal.Information` used in `waitid`. Correct. |

## Assessment

Excellent. The 65 methods follow a uniform pattern with no structural deviations. The `self = .init()` + opcode + target.apply + typed fields + data pattern is mechanical and correct. `@unsafe`/`@inlinable`/`borrowing`/`mutating` annotations are applied consistently.

The main area for improvement is type precision on a handful of raw integer parameters (`newDirFd: Int32`, `mode: UInt32`, `fd: Int32` in `message`, `fd: UInt32` in `install`). These leak untyped values into the public API. The `zeroCopyFlags: Priority` naming is also imprecise.
