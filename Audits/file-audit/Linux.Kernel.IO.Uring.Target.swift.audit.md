# Audit: Linux.Kernel.IO.Uring.Target.swift

**File**: `/Users/coen/Developer/swift-linux-foundation/swift-linux-standard/Sources/Linux Kernel IO Uring Standard/Linux.Kernel.IO.Uring.Target.swift`
**Lines**: 81

## Findings

| # | Severity | Rule | Line(s) | Finding |
|---|----------|------|---------|---------|
| 1 | Pass | API-NAME-001 | 36 | `Kernel.IO.Uring.Target` -- correct Nest.Name. |
| 2 | Pass | API-NAME-002 | 59 | `apply(to:)` -- single-concept method name. |
| 3 | Pass | API-IMPL-005 | entire | Single type declared (`Target`). |
| 4 | Pass | API-IMPL-008 | 36-52 | Enum body contains only cases. `apply(to:)` is in a separate extension. |
| 5 | Pass | API-ERR-001 | N/A | No throwing functions. |
| 6 | Pass | IMPL-INTENT | all | Case names are self-documenting: `.descriptor`, `.registered`, `.allocate`, `.none`. Doc comment explains the discriminant mechanism (fd field + IOSQE_FIXED_FILE flag). |
| 7 | Pass | IMPL-002 | 64 | `fd._rawValue` -- this is the correct boundary. `_rawValue` extraction happens inside `apply(to:)` which is `@usableFromInline internal`. The `.rawValue` is not exposed at public call sites. |
| 8 | Pass | IMPL-064 | 36 | `~Copyable` -- correct. The `.descriptor` case holds a ~Copyable `Kernel.Descriptor`, so the enum must be ~Copyable. |
| 9 | Pass | IMPL-067 | N/A | `apply(to:)` is non-consuming (reads self). Could add `borrowing` annotation explicitly but the compiler infers it for ~Copyable enums. |
| 10 | Pass | IMPL-COMPILE | 62-77 | The `switch` in `apply(to:)` handles all four cases exhaustively. The `.registered` and `.allocate` cases automatically insert `.fixedFile` into entry flags -- the flag/field agreement is compiler-enforced by construction. |
| 11 | Pass | Unnecessary API | N/A | Four cases, one method. Minimal. |
| 12 | Pass | Doc comments | 22-51 | Type has a thorough doc comment explaining the sum-type nature and each case. |
| 13 | Pass | Unsafe ops | N/A | No unsafe operations. |
| 14 | Minor | Precise modeling | 41 | `.registered(UInt32)` -- the associated value is a raw UInt32. This could use `Kernel.IO.Uring.Fixed.Index` or similar phantom-typed index for stronger type safety at the call site. |
| 15 | Info | Visibility | 58-59 | `apply(to:)` is `@usableFromInline` (no explicit access level = `internal`). This is correct -- it is called from `@inlinable` methods in Entry+Prepare.swift but should not be public API. |

## Assessment

Clean and well-designed. The Target enum makes the io_uring fd-field/IOSQE_FIXED_FILE sum type explicit in the Swift type system. The `apply(to:)` method centralizes the fd/flag injection, preventing flag/field disagreement by construction.

One minor improvement: the `.registered(UInt32)` associated value could be a typed index.
