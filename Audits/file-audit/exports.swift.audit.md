# Audit: exports.swift

**File**: `/Users/coen/Developer/swift-linux-foundation/swift-linux-standard/Sources/Linux Kernel IO Uring Standard/exports.swift`
**Lines**: 2

## Findings

| # | Severity | Rule | Line(s) | Finding |
|---|----------|------|---------|---------|
| 1 | Pass | API-NAME-001 | N/A | No type declarations. |
| 2 | Pass | API-NAME-002 | N/A | No methods or properties. |
| 3 | Pass | API-IMPL-005 | N/A | No type declarations. |
| 4 | Pass | API-ERR-001 | N/A | No throwing functions. |
| 5 | Pass | IMPL-002 | N/A | No raw value access. |
| 6 | Pass | All rules | 1 | `@_exported public import Linux_Standard_Core` -- standard re-export pattern. This gives consumers access to the `Kernel`, `Linux`, and core namespace types without additional imports. |
| 7 | Info | Missing exports | 1 | Only `Linux_Standard_Core` is re-exported. Consumers will need explicit imports for primitives types used in the public API (`Kernel.Descriptor`, `Kernel.IO.Uring.Operation.Data`, etc.) unless those are already re-exported transitively through `Linux_Standard_Core`. Verify the transitive export chain covers all public API parameter types. |
| 8 | Info | Doc comments | N/A | No doc comment on the export. Acceptable for a single-line export file. |

## Assessment

Minimal and correct. Single re-export line. The only question is whether `Linux_Standard_Core` transitively exports everything consumers need -- if not, additional `@_exported` imports may be needed for types like `Kernel.Descriptor`, `Kernel.Memory.Address`, etc.
