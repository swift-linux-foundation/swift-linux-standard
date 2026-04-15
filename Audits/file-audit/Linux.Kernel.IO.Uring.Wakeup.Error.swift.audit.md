# Audit: Linux.Kernel.IO.Uring.Wakeup.Error.swift

## Verdict: PASS

## Findings

| Rule | Status | Notes |
|------|--------|-------|
| [API-NAME-001] Nest.Name | PASS | `Kernel.IO.Uring.Wakeup.Error` — properly nested |
| [API-NAME-002] No compound identifiers | PASS | Cases `eventfd`, `register` — single-word |
| [API-IMPL-005] One type per file | PASS | Single `Error` enum |
| [API-IMPL-008] Minimal type body | PASS | Two cases, no computed properties, no methods |
| [API-ERR-001] Typed throws | N/A | Error type itself, not a throwing site |
| [API-ERR-002] Nested error types | PASS | Nested inside `Kernel.IO.Uring.Wakeup` |
| [IMPL-064] ~Copyable | N/A | Error enum is Copyable — correct for error types |
| [IMPL-067] Ownership | N/A | Enum, no parameters needing annotation |
| [IMPL-COMPILE] Compiler-enforced | PASS | `Swift.Error`, `Sendable`, `Equatable`, `Hashable` conformances |
| Raw values in public API | PASS | Cases wrap `Kernel.Error.Code` — typed, not raw |
| Doc comments | PASS | Type and both cases have doc comments |
| Error modeling | PASS | Two cases map 1:1 to the two operations in `createWakeup()` |

## Notes

Well-modeled error type. Each case corresponds to exactly one failure point in the wakeup creation sequence: eventfd syscall failure and io_uring registration failure. Both wrap `Kernel.Error.Code` for platform detail without leaking raw integers.
