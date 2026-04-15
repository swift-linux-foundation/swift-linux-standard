# Audit: Linux.Kernel.IO.Uring.Submission.Queue.Entry.swift

**File**: `/Users/coen/Developer/swift-linux-foundation/swift-linux-standard/Sources/Linux Kernel IO Uring Standard/Linux.Kernel.IO.Uring.Submission.Queue.Entry.swift`
**Lines**: 513

## Findings

| # | Severity | Rule | Line(s) | Finding |
|---|----------|------|---------|---------|
| 1 | Pass | API-NAME-001 | 61 | `Kernel.IO.Uring.Submission.Queue.Entry` -- correct Nest.Name. |
| 2 | Pass | API-NAME-002 | 79-133 | Public accessors use single-concept names: `opcode`, `flags`, `priority`, `offset`, `addr`, `len`, `data`, `personality`. No compound names. |
| 3 | Pass | API-NAME-002 | 141-225 | Internal union accessors use compound names (`atFlags`, `fileAdvice`, `syncRangeFlags`, etc.) but all are `@usableFromInline internal`. Exception for `package` scope applies per feedback_compound_package_scope. The file even cites this at line 138-139. |
| 4 | Pass | API-IMPL-005 | entire | Single type declared (`Entry`). |
| 5 | Pass | API-IMPL-008 | 61-74 | Struct body has one stored property (`cValue`) + two inits. Clean. All accessors in extensions. |
| 6 | Pass | API-ERR-001 | N/A | No throwing functions in this file. |
| 7 | Pass | IMPL-INTENT | all | Accessors read as intent. The MARK sections organize by semantic domain (public accessors, single-field semantic, raw field, typed union). WHY comments where needed. |
| 8 | Pass | IMPL-002 | all | `.rawValue` access is consistently pushed to the internal accessor boundary. Public properties return domain types. Internal accessors extract/inject `.rawValue` so `@inlinable` callers in Entry+Prepare.swift never touch raw values. |
| 9 | Pass | IMPL-064 | 61 | `~Copyable` -- prevents accidental SQE value copies that would be disconnected from the ring. |
| 10 | Pass | IMPL-067 | N/A | Accessors are all get/set on a value type. No consuming/borrowing needed. |
| 11 | Pass | IMPL-COMPILE | 61 | ~Copyable ensures SQE slot identity. Typed accessors enforce domain-correct values at compile time. |
| 12 | Minor | Unnecessary API | 111-113 | `addr` is `public var addr: UInt64`. This is a raw address field with no type safety. All legitimate uses go through `setAddr(_:)` internally. Consider making this `internal` and providing typed public overloads only. |
| 13 | Minor | Unnecessary API | 93-95 | `opFlags` returns raw `Int32`. This leaks an untyped value. Legitimate uses go through typed internal accessors (`atFlags`, `fileAdvice`, etc.). Consider making internal. |
| 14 | Info | Doc comments | 141-511 | Internal accessors have doc comments. This is thorough but the comments are brief (one line). Acceptable for internal API. |
| 15 | Pass | Unsafe ops | 286-304 | `setAddr`, `setOffset`, `setAddr3` are all `@unsafe` and `@usableFromInline internal`. The unsafe boundary is correctly drawn: public methods in Entry+Prepare.swift propagate `@unsafe` to callers. |
| 16 | Minor | Precise modeling | 349-353 | `xattrDisposition` getter returns `.createOrReplace` unconditionally (ignores stored bits). This is a one-way accessor -- get always returns default, set writes raw bits. The getter is misleading; it should either decode the stored bits or be a set-only pattern. |
| 17 | Info | Precise modeling | 399, 507-509 | `epollMaxEvents` and `bufferStartID` use `Int32`/`UInt16` directly. These could have phantom-tagged wrappers but the types are used only in one place each. Low priority. |

## Assessment

Strong. The two-tier accessor architecture (public typed properties + internal union accessors) cleanly separates the public API from the C union mechanics. The `@usableFromInline internal` compound names are correctly scoped and documented.

Three items worth tracking:
1. `addr` and `opFlags` leak raw types at the public boundary -- consider restricting visibility.
2. The `xattrDisposition` getter is a lossy read (always returns default). Either decode stored bits or restructure as write-only.
