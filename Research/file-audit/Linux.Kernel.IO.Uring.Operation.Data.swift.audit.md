# Audit: Linux.Kernel.IO.Uring.Operation.Data.swift

## Summary

`typealias Data = Tagged<Kernel.IO.Uring.Operation, UInt64>` -- the `user_data` field of SQEs/CQEs.

## Findings

| ID | Status | Finding |
|----|--------|---------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Operation.Data` -- proper Nest.Name |
| [API-NAME-003] | PASS | Maps `user_data` from `struct io_uring_sqe` / `struct io_uring_cqe` |
| [API-IMPL-005] | PASS | Single typealias + extensions |
| [API-IMPL-008] | PASS | Typealias delegates to Tagged; extensions add only pointer inits and `.zero` |
| [IMPL-002] | PASS | Uses `Tagged` -- rawValue access goes through Tagged's controlled API |
| [IMPL-006] | PASS | `UInt64` matches kernel's `__u64 user_data` field |
| [IMPL-064] | PASS | Tagged is Copyable by design -- Data is a value identifier round-tripped through the kernel |

## Protocol Conformances

Inherited from `Tagged`: `Equatable`, `Hashable`, `Sendable`, `RawRepresentable`.

- Missing: `CustomStringConvertible` -- could be useful for debugging (show hex representation of pointer-based data). Minor.

## Issues

1. **Pointer init naming inconsistency**: `init(_ pointer: UnsafeRawPointer)` uses unlabeled parameter, while `init<T>(pointer: UnsafePointer<T>)` and `init<T>(pointer: UnsafeMutablePointer<T>)` use labeled `pointer:`. The unlabeled init should either also be labeled or the labeled ones should also be unlabeled, for consistency. Current state creates asymmetry at the call site:
   ```swift
   Data(rawPtr)           // unlabeled
   Data(pointer: typedPtr) // labeled
   ```

2. **Missing `unsafePointer` accessor**: There are inits from pointers but no way to recover the pointer from Data. This is intentional (it would be `@unsafe` and rarely needed at L2), but worth noting -- L3 may need `var unsafeRawPointer: UnsafeRawPointer?`.

3. **`__unchecked` init usage**: All pointer inits use `self.init(__unchecked: (), ...)`. This is correct since the value is derived from a valid pointer, but the `__unchecked` label pattern (empty tuple first argument) is a Tagged convention.

## Verdict

Well-modeled. The pointer init label inconsistency is the only concrete issue.
