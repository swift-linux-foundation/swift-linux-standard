# Audit: Linux.Kernel.IO.Uring.Params.swift

## Summary

Dual-purpose struct: user provides setup config, kernel fills ring metadata. The most complex file in the audit scope.

## Findings

| Rule | Status | Detail |
|------|--------|--------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Params` -- proper Nest.Name |
| [API-NAME-002] | OBSERVATION | `.sqEntries`, `.cqEntries`, `.sqOff`, `.cqOff` -- compound abbreviations, but these mirror the C struct field names (`sq_entries`, `cq_entries`, `sq_off`, `cq_off`). Spec-justified under [API-NAME-003]. |
| [API-IMPL-005] | PASS | Single type declaration (`Params`) plus internal conversion extension |
| [API-IMPL-008] | PASS | Properties + two inits + one computed property |
| [API-ERR-001] | N/A | No throwing functions in this file (setup() is in Uring.swift) |
| [IMPL-002] | PASS | No raw integers in public API -- `Submission.Count`, `Completion.Count`, `Setup.Options`, `Features`, typed offsets |
| [IMPL-006] | PASS | All stored properties use typed wrappers |
| [IMPL-COMPILE] | PASS | `private(set)` on kernel-filled fields prevents user mutation |
| [IMPL-INTENT] | PASS | Reads as intent: "params has entries, flags, submission config, features, offsets" |

## Design Assessment

The dual-purpose nature (input + output) is well-handled:
- User-settable: `flags`, `submission` (public var)
- Kernel-filled: `sqEntries`, `cqEntries`, `features`, `sqOff`, `cqOff` (public private(set))

This correctly models the `io_uring_params` C struct semantics where the kernel overwrites certain fields.

## Potential Improvement

The `init(flags:submission:)` public init does not expose `cqEntries` as a parameter. When using `.cqSize` setup flag, users need to set the CQ entry count. Currently there is no way to do this through the typed API -- they would need to go through the C boundary. Consider adding an optional `cqEntries` parameter to the public init, gated on the `.cqSize` flag presence.

Similarly, `wq_fd` (for `.attachWq`) has no typed representation in `Params`.

## C Boundary

`cValue` and `init(_ cParams:)` are both `internal` -- correct. The C boundary conversion is clean. The `__unchecked` init pattern for `Count` types is consistent with project conventions.

## Doc Comments

Present and thorough with usage example showing the dual-purpose lifecycle.
