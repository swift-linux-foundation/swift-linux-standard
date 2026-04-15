# Audit: Linux.Kernel.IO.Uring+Wakeup.swift

## Verdict: PASS (1 observation, 0 defects)

## Findings

| Rule | Status | Notes |
|------|--------|-------|
| [API-NAME-001] Nest.Name | PASS | `createWakeup()` on `Kernel.IO.Uring` — single verb |
| [API-NAME-002] No compound identifiers | PASS | `createWakeup` could be read as compound, but `Wakeup` is a noun (the namespace), not a verb modifier. The method creates a `Wakeup.Result`. Acceptable. |
| [API-IMPL-005] One type per file | PASS | No new types declared. Two extensions on existing types. |
| [API-IMPL-008] Minimal type body | PASS | One public method, one private helper, one internal computed property |
| [API-ERR-001] Typed throws | PASS | `throws(Wakeup.Error)` — concrete typed throws throughout |
| [API-ERR-002] Nested error types | PASS | Uses `Wakeup.Error`, defined in sibling file |
| [IMPL-064] ~Copyable | PASS | `Kernel.Event.Descriptor` is `~Copyable`; `consume eventfd` transfers ownership into `Wakeup.Result` |
| [IMPL-067] Ownership | PASS | `consuming` transfer of eventfd into Result |
| [IMPL-COMPILE] Compiler-enforced | PASS | Typed throws with `do throws(T)` scoping; error cases matched exhaustively |
| Raw values in public API | PASS | Public API returns `Wakeup.Result` — typed. Raw fd extraction (`_rawValue`, `rawDescriptor:`) is internal/`@_spi` only |
| Doc comments | PASS | Both methods and the `code` property have doc comments |

## Observation: `Kernel.IO.Uring.Error.code` extension placement

Lines 75-85 add `var code: Kernel.Error.Code` on `Kernel.IO.Uring.Error`. This is a convenience used only by `createWakeup()` to translate `Kernel.IO.Uring.Error` into `Wakeup.Error`. It works, but it lives in this file rather than in the Error's own file. Since it is `internal` visibility, this is not a defect — it is an implementation detail scoped to where it is used.

## Observation: Raw fd in @Sendable closure

Line 48: `let rawEfd = eventfd.descriptor._rawValue` extracts a raw `Int32` to capture in the `@Sendable` closure. This is the only viable pattern because `~Copyable` types cannot be captured in `@Sendable` closures. The raw value never surfaces in the public API. The comment at lines 46-47 documents the rationale. This is correct and necessary.

## Architecture

The file orchestrates three operations — eventfd creation, io_uring registration, wakeup channel construction — each of which can fail independently. The two-error-type design (`Kernel.Event.Descriptor.Error` caught and re-thrown as `Wakeup.Error.eventfd`, `Kernel.IO.Uring.Error` caught and re-thrown as `Wakeup.Error.register`) keeps the public error surface minimal and domain-specific. The raw-fd extraction for the `@Sendable` closure is the only raw value in the file, correctly `@_spi(Syscall)` gated.
