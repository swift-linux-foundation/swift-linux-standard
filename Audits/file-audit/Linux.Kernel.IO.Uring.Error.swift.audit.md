# Audit: Linux.Kernel.IO.Uring.Error.swift

## Summary

Error enum for io_uring syscalls. Three operation-specific cases plus `interrupted`.

## Findings

| Rule | Status | Detail |
|------|--------|--------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Error` -- proper Nest.Name |
| [API-NAME-002] | PASS | No compound identifiers |
| [API-IMPL-005] | PASS | Single type declaration (`Error`) plus `CustomStringConvertible` extension |
| [API-IMPL-008] | PASS | Four cases + description computed property |
| [API-ERR-001] | PASS | This IS the typed error. Functions in Uring.swift throw `Kernel.IO.Uring.Error` -- fully typed throws. |
| [IMPL-006] | PASS | Associated values use `Kernel.Error.Code` -- typed |
| [IMPL-COMPILE] | PASS | Enum exhaustiveness enforced by compiler |

## Design Assessment

The error design is clean:
- `.setup(Kernel.Error.Code)` -- wraps setup syscall errors
- `.enter(Kernel.Error.Code)` -- wraps enter syscall errors
- `.register(Kernel.Error.Code)` -- wraps register syscall errors
- `.interrupted` -- EINTR special case (no associated value since the code is always EINTR)

Each case maps 1:1 to a syscall, which is correct at L2. The `Kernel.Error.Code` associated value preserves the errno semantics.

## Observation

The `.interrupted` case is only produced by `enter()` (checked in Uring.swift line 229-230). The `setup()` and `register()` syscalls do not special-case EINTR. This is correct -- `io_uring_enter` is the only interruptible one.

However, an EINTR from `io_uring_setup` would currently be reported as `.setup(.posix(EINTR))` rather than `.interrupted`. If this inconsistency matters, `setup` should also check for EINTR. In practice, `io_uring_setup` is not interruptible, so this is academic.

## Doc Comments

Present on type and all cases. Usage example shows error handling pattern. `CustomStringConvertible` provides clean debugging output.
