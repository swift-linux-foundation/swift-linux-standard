# Audit: swift-linux-primitives

## Code Surface — 2026-04-10

### Scope

- **Target**: `Linux Kernel IO Uring Primitives` (swift-linux-primitives)
- **Skill**: code-surface — [API-NAME-001], [API-NAME-002], [API-NAME-003], [API-ERR-001], [API-ERR-002], [API-ERR-003], [API-IMPL-005], [API-IMPL-006], [API-IMPL-007], [API-IMPL-008]
- **Files**: 67 source files in `Sources/Linux Kernel IO Uring Primitives/`

### Findings

| # | Severity | Rule | Location | Finding | Status |
|---|----------|------|----------|---------|--------|
| 1 | HIGH | [API-NAME-002] | Linux.Kernel.IO.Uring.swift | `nextEntry()` → `ring.submission.next()` | RESOLVED 2026-04-10 |
| 2 | HIGH | [API-NAME-002] | Linux.Kernel.IO.Uring.swift | `commitEntry()` → `ring.submission.commit()` | RESOLVED 2026-04-10 |
| 3 | HIGH | [API-NAME-002] | Linux.Kernel.IO.Uring.swift | `drainCompletions(limit:_:)` → `ring.completion.drain(limit:_:)` | RESOLVED 2026-04-10 |
| 4 | MEDIUM | [API-NAME-002] | Linux.Kernel.IO.Uring.swift | `resetPending()` → `ring.submission.reset()` | RESOLVED 2026-04-10 |
| 5 | MEDIUM | [API-NAME-002] | Linux.Kernel.IO.Uring.swift | `pendingSubmissions` → `ring.submission.pending` | RESOLVED 2026-04-10 |
| 6 | MEDIUM | [API-IMPL-005] | Linux.Kernel.IO.Uring.swift | `Space` extracted to `Linux.Kernel.IO.Uring.Space.swift` | RESOLVED 2026-04-10 |
| 7 | MEDIUM | [API-IMPL-006] | Completion.Queue.Entry.Typed.swift | Renamed to `Completion.Queue.Entry+Multishot.swift` | RESOLVED 2026-04-10 |
| 8 | HIGH | [API-IMPL-008] | Submission.Queue.Entry.Prepare.swift | `Prepare` refactored to ~Copyable pointer-based struct. Methods in extensions. | RESOLVED 2026-04-10 (by prior commit 6239f5e) |
| 9 | LOW | [API-IMPL-005] | Linux.Kernel.IO.Uring.Send.swift | `Zero` extracted to `Linux.Kernel.IO.Uring.Send.Zero.swift` | RESOLVED 2026-04-10 |
| 10 | LOW | [API-IMPL-008] | Linux.Kernel.IO.Uring.Params.swift | `cValue` moved to extension | RESOLVED 2026-04-10 |
| 11 | LOW | [API-NAME-002] | Completion.Queue.Entry.swift:109 | `errorNumber` — "error number" is POSIX terminology | DEFERRED — spec-mirroring argument reasonable |

### Compliant Areas

| Rule | Status | Notes |
|------|--------|-------|
| [API-NAME-001] Nest.Name | PASS (67/67) | No compound type names anywhere. |
| [API-NAME-002] OptionSet members | PASS | `sqPoll`, `ioLink`, `coopTaskrun` etc. — all spec-mirroring exemptions (`IORING_SETUP_*`, `IOSQE_*`). |
| [API-NAME-002] Opcode accessors | PASS | `.read.standard`, `.socket.accept`, `.send.zero.copy` — all nested. |
| [API-NAME-002] Prep method names | PASS | `prepare.read(...)`, `prepare.nop(...)` — single-word verbs. |
| [API-NAME-002] Boolean properties | PASS | `isSuccess`, `isError`, `isCancelled`, `hasMore` — standard boolean naming. |
| [API-NAME-003] Spec-mirroring | PASS | All opcode values and flag bits match kernel `io_uring.h`. |
| [API-ERR-001] Typed throws | PASS | All three syscalls: `throws(Kernel.IO.Uring.Error)`. |
| [API-ERR-002] Nested errors | PASS | `Kernel.IO.Uring.Error`, `Kernel.IO.Uring.Wakeup.Error`. |
| [API-ERR-003] Failure description | PASS | `.setup(Code)`, `.enter(Code)`, `.register(Code)`, `.interrupted`. |
| [API-IMPL-005] One type/file | PASS (69/69) | All resolved. `Space` and `Send.Zero` extracted. |
| [API-IMPL-006] File naming | PASS (69/69) | `Typed.swift` renamed to `+Multishot.swift`. |
| [API-IMPL-007] Extension files | PASS | `+Wakeup.swift` uses `+` suffix correctly. |

### Summary

11 findings: 4 high, 3 medium, 3 low, 1 deferred. **10 RESOLVED, 1 DEFERRED.**

Ring instance methods refactored to nested accessor pattern: `ring.submission.next()`, `ring.submission.commit()`, `ring.submission.pending`, `ring.submission.reset()`, `ring.completion.drain(limit:_:)`. Both `Submission.Access` and `Completion.Access` are `~Copyable` pointer-based accessor structs. L3 consumer (`swift-kernel/Kernel.Completion+IOUring.swift`) updated to match.

---

## Implementation (Domain Modelling) — 2026-04-09

### Scope

- **Target**: `Linux Kernel IO Uring Primitives` (63 source files)
- **Skill**: implementation — [IMPL-INTENT], [IMPL-002], [IMPL-006], [IMPL-010], [IMPL-COMPILE]
- **Focus**: Domain modelling quality. All raw `Int`, `UInt32`, `UInt64`, `Int32`, `UInt16`, `UInt8` in public API surfaces, stored properties, and type definitions.
- **Files**: 63 source files in `Sources/Linux Kernel IO Uring Primitives/`

### Existing Infrastructure

The ecosystem provides typed infrastructure that io_uring SHOULD be using but doesn't:

**Ring Index Infrastructure** (the exact abstraction io_uring needs):

| Ecosystem Type | Package | Purpose | io_uring equivalent |
|----------------|---------|---------|---------------------|
| `Index<T>.Modular` | cyclic-index-primitives | Runtime-capacity modular index with wrapping successor/physical | SQ/CQ head/tail (UInt32 & mask) |
| `Index<T>.Cyclic<N>` | cyclic-index-primitives | Compile-time cyclic index with auto-wrap arithmetic | — (io_uring uses runtime capacity) |
| `Buffer.Ring.Header` | buffer-primitives | Ring header: `head: Index<E>`, `count: Index<E>.Count`, `capacity: Index<E>.Count` | Uring stored properties (9× raw UInt32) |
| `Index<T>.Count` | index-primitives | `Tagged<T, Cardinal>` — typed element count | setup entries, enter toSubmit/minComplete, pendingSubmissions |
| `Index<T>` | index-primitives | `Tagged<T, Ordinal>` — typed position | SQ/CQ head/tail positions |

**Memory Infrastructure** (already partially used):

| Ecosystem Type | Package | Purpose | io_uring status |
|----------------|---------|---------|-----------------|
| `Kernel.Memory.Address` | kernel-primitives | Typed address with `.mutablePointer` | ✓ Used for mmap regions |
| `Kernel.Memory.Map.Region` | kernel-primitives | `base: Address`, `length: File.Size`, `Span<UInt8>` access | ✗ Not used — stores raw addr+size pairs |
| `Kernel.File.Size` | kernel-primitives | Typed byte magnitude | ✓ Used for mmap sizes |
| `Memory.Address.Offset` | memory-primitives | Typed byte displacement | ✗ Not used — Offsets structs are raw UInt32 |

**Dimension Infrastructure** (partially adopted):

| Ecosystem Type | Package | Purpose | io_uring status |
|----------------|---------|---------|-----------------|
| `Coordinate.X<Space>.Value<T>` | dimension-primitives | Typed position | ✓ Used for Offset |
| `Magnitude<Space>.Value<T>` | dimension-primitives | Non-directional size | ✓ Used for Length |
| `Tagged<Tag, RawValue>` | dimension-primitives | Zero-cost phantom wrapper | ✓ Used for Operation.Data, Personality.ID |

**Cardinal/Ordinal Arithmetic** (not used at all):

| Operation | Infrastructure | io_uring does instead |
|-----------|---------------|----------------------|
| `.zero`, `.one` | `Cardinal.Protocol` | `0`, `1` literals |
| `count + .one` | `Cardinal.Protocol.+` | `_pendingCount &+= 1` |
| `position.successor` | `Ordinal.Protocol` | `head &+= 1` |
| `slot < capacity` | Typed comparison | `sqEntries &- (tail &- sqHead.pointee) > 0` |
| `Index.Modular.physical(forLogical:head:capacity:)` | cyclic-index-primitives | `Int(tail & sqMask)` |

**Key insight**: `Buffer.Ring.Header` is the EXACT domain model for io_uring's SQ/CQ ring state. The difference is that io_uring's rings are shared-memory (mmap'd kernel pointers) rather than process-owned heap storage. But the INDEX DISCIPLINE — head, tail, count, mask, wrapping — is identical.

### Findings

| # | Severity | Rule | Location | Finding | Status |
|---|----------|------|----------|---------|--------|
| 1 | CRITICAL | [IMPL-006] | Uring.swift:51-65 | **Ring stored properties are all raw UInt32.** `sqHead`, `sqTail`, `sqMask`, `sqEntries`, `sqArray` (SQ); `cqHead`, `cqTail`, `cqMask` (CQ); `_pendingCount` — 9 stored properties storing ring indices, masks, and counts as bare `UInt32`. These are the core of the data structure. Needs: `Ring.Index` (for head/tail), `Ring.Mask`, `Ring.Count` (for entries, pending). | OPEN |
| 2 | CRITICAL | [IMPL-002] | Uring.swift:158 | **`setup(entries: UInt32)` — public factory parameter is raw.** This is the primary entry point. Should be a typed count: `Submission.Queue.Count` or similar. | OPEN |
| 3 | CRITICAL | [IMPL-002] | Uring.swift:193-194 | **`enter(toSubmit: UInt32, minComplete: UInt32)` — both parameters are raw.** Core syscall bridge. `toSubmit` is a submission count, `minComplete` is a completion count. These are fundamentally different quantities mixed under the same `UInt32`. | OPEN |
| 4 | CRITICAL | [IMPL-002] | Uring.swift:236 | **`register(count: UInt32)` — parameter is raw.** Registration item count. | OPEN |
| 5 | CRITICAL | [IMPL-002] | Uring.swift:339 | **`pendingSubmissions` returns `UInt32`.** Public property on the ring struct. Should return typed count. | OPEN |
| 6 | CRITICAL | [IMPL-010] | Uring.swift:288-290 | **`Int(params.sqOff.array)`, `Int(params.sqEntries)` etc — 12 raw Int casts in init.** Size calculations for mmap regions chain through raw `Int`. These should use typed `Kernel.Memory.Address` / `Kernel.File.Size` arithmetic. | OPEN |
| 7 | CRITICAL | [IMPL-010] | Uring.swift:349-354 | **Ring index masking uses raw UInt32 arithmetic.** `Int(tail & sqMask)`, `UInt32(idx)`, wrapping add — pure mechanism at what should be the intent layer. Needs `Ring.Index` with masking built in. | OPEN |
| 8 | CRITICAL | [IMPL-006] | Params.swift:55-58 | **`Params.sqEntries: UInt32` and `Params.cqEntries: UInt32`.** Ring sizes are the first thing consumers read from params. Should be typed counts. | OPEN |
| 9 | HIGH | [IMPL-002] | Params.swift:67 | **`Params.features: UInt32`.** Kernel feature bitmask exposed as raw integer. Should be a typed `Features` OptionSet. | OPEN |
| 10 | HIGH | [IMPL-002] | Params.Submission.Thread.swift:19-22 | **`Thread.cpu: UInt32` and `Thread.idle: UInt32`.** CPU is a processor ID, idle is milliseconds. Two completely different domains collapsed to the same raw type. | OPEN |
| 11 | HIGH | [IMPL-006] | SQ.Offsets.swift:28-34 | **All 7 SQ Offsets fields are raw `UInt32`.** `head`, `tail`, `ringMask`, `ringEntries`, `flags`, `dropped`, `array` — byte offsets into the mmap'd SQ ring region. These are `Kernel.Memory.Address.Offset` or a dedicated `Ring.Offset` type. | OPEN |
| 12 | HIGH | [IMPL-006] | CQ.Offsets.swift:28-34 | **All 7 CQ Offsets fields are raw `UInt32`.** Same issue as SQ Offsets: `head`, `tail`, `ringMask`, `ringEntries`, `overflow`, `cqes`, `flags`. | OPEN |
| 13 | HIGH | [IMPL-002] | SQE.swift:71 | **`Entry.flags: UInt8` getter/setter.** SQE flags exposed as raw byte. Already has `Submission.Queue.Entry.Flags` type — this property should use it. | OPEN |
| 14 | HIGH | [IMPL-002] | SQE.swift:77 | **`Entry.opFlags: Int32` getter/setter.** Operation-specific flags as raw signed integer. Should be typed per-operation or use `Op.Flags`. | OPEN |
| 15 | HIGH | [IMPL-002] | SQE.swift:95 | **`Entry.addr: UInt64` getter/setter.** Buffer address as raw 64-bit value. Should use `Kernel.Memory.Address` or `UnsafeRawPointer` wrapper. | OPEN |
| 16 | HIGH | [IMPL-002] | CQE.swift:72 | **`Entry.res: Int32`.** Operation result code — the primary output of every io_uring operation. Should be `Kernel.IO.Uring.Result` or at minimum `Kernel.Error.Code`-aware. | OPEN |
| 17 | HIGH | [IMPL-002] | CQE.swift:79 | **`Entry.flags: UInt32`.** CQE flags as raw integer. Already has `Completion.Queue.Entry.Flags` type — this property should use it. | OPEN |
| 18 | HIGH | [IMPL-002] | Prepare.swift:155-228 | **SQE prepare methods take raw Int32/UInt32 for socket params.** `accept(addrLen: UInt32, flags: Int32)`, `connect(addrLen: UInt32)`, `send(flags: Int32)`, `recv(flags: Int32)` — 6 parameters across 4 methods. Should use `Socket.Flags`, `Socket.Address.Length`. | OPEN |
| 19 | HIGH | [IMPL-006] | Mmap.Offset.swift:41-51 | **Mmap offset constants are raw `Int64`.** `.sqRing = 0`, `.cqRing = 0x8000000`, `.sqes = 0x1000_0000` — magic mmap offsets. Should use `Kernel.File.Offset` or `Kernel.Memory.Address.Offset`. | OPEN |
| 20 | MEDIUM | [IMPL-002] | CQE.Entry.Buffer.swift:30-32 | **Buffer ID extracted as raw `UInt16` via bitwise shift on `UInt32` flags.** Should return typed `Buffer.Index` or `Buffer.ID`. | OPEN |
| 21 | MEDIUM | [IMPL-002] | SQE.Entry.Op.swift:37-44 | **`Op` init takes `flags: Int32`.** Raw signed integer for operation-specific flags. | OPEN |
| 22 | MEDIUM | [IMPL-INTENT] | Uring.swift:393-401 | **CQ drain loop is pure mechanism.** `var head = cqHead.pointee; while head != tail { cqes[Int(head & cqMask)]; head &+= 1 }` — index masking, wrapping add, raw pointer indexing. Should read as intent: `ring.completions.drain(limit:visitor:)`. | OPEN |
| 23 | MEDIUM | [IMPL-INTENT] | Uring.swift:348-354 | **SQ entry acquisition is pure mechanism.** `sqEntries &- (tail &- sqHead.pointee) > 0`, `sqArray[idx] = UInt32(idx)` — ring fullness check and index assignment should be encapsulated. | OPEN |
| 24 | LOW | [IMPL-006] | Priority.swift:32 | **`Priority.rawValue: UInt16`** with public init. Already a `RawRepresentable` struct but uses raw backing. Could use `Tagged<Kernel.IO.Uring.Priority, UInt16>`. | OPEN |
| 25 | LOW | [IMPL-006] | Buffer.Group.swift:33 | **`Buffer.Group.rawValue: UInt16`** — same pattern as Priority. Hand-rolled RawRepresentable instead of `Tagged`. | OPEN |
| 26 | LOW | [IMPL-006] | Buffer.Index.swift:27 | **`Buffer.Index.rawValue: UInt16`** — same pattern. | OPEN |

### Systemic Patterns

**Pattern A: The Ring has no domain model.** The core ring abstraction — head, tail, mask, entries, pending count — is entirely raw `UInt32`. This is the highest-impact deficiency. A proper ring index type with masking built into its arithmetic would eliminate findings #1, #5, #6, #7, #22, #23 as corollaries.

**Proposed domain types for the Ring:**

```
Kernel.IO.Uring.Ring.Index      — UInt32-backed, wrapping arithmetic, mask-aware
Kernel.IO.Uring.Ring.Mask       — power-of-2 mask, used by Index for wrapping
Kernel.IO.Uring.Submission.Count — UInt32-backed cardinal for SQ quantities
Kernel.IO.Uring.Completion.Count — UInt32-backed cardinal for CQ quantities
```

**Pattern B: Offsets structs are byte-offset bags.** Both `Submission.Queue.Offsets` and `Completion.Queue.Offsets` are 7-field structs of raw `UInt32` representing byte offsets into mmap'd regions. These should use a typed `Ring.Byte.Offset` so the `init(descriptor:params:)` factory can do typed pointer arithmetic instead of 12 raw `Int()` casts.

**Pattern C: SQE/CQE properties re-expose raw C fields.** The `Entry` types have typed flag/data types (`Entry.Flags`, `Completion.Queue.Entry.Flags`, `Operation.Data`) but the entry properties return raw integers instead of these types. The typed types exist but aren't used at the accessor layer.

**Pattern D: Public API parameters use raw integers for counts.** `setup(entries:)`, `enter(toSubmit:minComplete:)`, `register(count:)`, and `pendingSubmissions` all traffic in `UInt32`. These are the public-facing ring operations — the API consumers actually call. Fixing these is the highest-visibility improvement.

**Pattern E: Socket/network parameters are raw.** The `prepare` methods for accept, connect, send, recv pass through raw `Int32` for socket flags and `UInt32` for address lengths. These should use types from a socket primitives layer or at minimum local typed wrappers.

### Recommended Type Catalog

**Adopt from ecosystem** (no new types needed — just import and use):

| Ecosystem Type | Replaces | Usage | Impact |
|----------------|----------|-------|--------|
| `Index<Submission.Queue.Entry>.Count` | `UInt32` in setup, enter, pendingSubmissions | SQ entry count | 5 public API sites |
| `Index<Completion.Queue.Entry>.Count` | `UInt32` in enter(minComplete:) | CQ entry count | 1 public API site |
| `Index<Submission.Queue.Entry>` | `UInt32` head/tail stored properties | SQ ring position | 4 stored properties |
| `Index<Completion.Queue.Entry>` | `UInt32` head/tail stored properties | CQ ring position | 4 stored properties |
| `Index.Modular.physical(forLogical:head:capacity:)` | `Int(tail & sqMask)` raw masking | Ring index wrapping | 2 internal sites |
| `Kernel.Memory.Map.Region` | `(sqRingAddr, sqRingSize)` pairs | mmap'd region ownership | 3 stored property pairs → 3 Region values |
| `Memory.Address.Offset` | `UInt32` in Offsets structs | Byte offset into mmap'd region | 14 fields (both Offsets structs) |

**Adopt from system-primitives** (ordinal complement to existing Count):

| Ecosystem Type | Package | Replaces | Notes |
|----------------|---------|----------|-------|
| `System.Processor.ID` (proposed) | system-primitives | `UInt32` cpu in Thread | `Tagged<System.Processor, Ordinal>` — ordinal complement to existing `System.Processor.Count = Tagged<System.Processor, Cardinal>`. Identifies WHICH processor, not HOW MANY. |

**New types to introduce** (io_uring-specific):

| Type | Backing | Replaces | Usage |
|------|---------|----------|-------|
| `Params.Features` | OptionSet struct, `UInt32` | `UInt32` in Params.features | Kernel feature flags |

**Existing types to connect** (types exist in io_uring but aren't used by entry accessors):

| Existing Type | Currently Returns | Should Return |
|---------------|-------------------|---------------|
| `Submission.Queue.Entry.Flags` | `UInt8` via `.flags` | `Entry.Flags` |
| `Completion.Queue.Entry.Flags` | `UInt32` via `.flags` | `Entry.Flags` |
| `Operation.Data` | `UInt64` via `.addr` | `Operation.Data` or `Kernel.Memory.Address` |

**Architecture note**: The ring index infrastructure (`Index.Modular`, `Index.Cyclic`) is the linchpin. Adopting it eliminates findings #1, #5, #6, #7, #22, #23 as corollaries — the wrapping arithmetic, masking, fullness checks all become method calls on typed indices instead of raw UInt32 bit manipulation.

### Summary

26 findings: 7 critical, 12 high, 4 medium, 3 low.
**Post-refactor (2026-04-09)**: 15 RESOLVED, 11 remain (mostly internal ring properties — deferred as kernel ABI boundary).

The io_uring target has strong namespace structure (`Kernel.IO.Uring.Submission.Queue.Entry.Prepare`) and already uses ecosystem types for some dimensions (`Offset`, `Length`, `Operation.Data`). But the core ring management, public API parameters, and entry accessor properties are entirely raw integers. The domain model is incomplete: typed wrappers exist but aren't connected to the API surface.

The systemic fix is a ring index type with mask-aware arithmetic, typed counts for submission/completion quantities, and entry accessors that return their companion typed types instead of raw integers. This is a breaking-change refactor with ~20 files affected.

---

## V6 Ergonomics — 2026-04-12

### Scope

- **Target**: V6 `~Escapable` Slot + mutating Entry architecture
- **Skills**: code-surface [API-NAME-002], [API-IMPL-005], [API-IMPL-008]; implementation [IMPL-INTENT], [IMPL-002], [IMPL-010], [IMPL-064], [IMPL-065], [IMPL-071], [IMPL-COMPILE]
- **Files**: `Slot.swift`, `Entry+Prepare.swift`, `Entry.swift` (accessors), `Target.swift`, `Uring.swift` (Ring.next)

### What V6 Got Right

| Aspect | Assessment |
|--------|-----------|
| `ring.next.entry.nop(data:)` | Reads as intent. Three-word chain: where (next slot), what (entry), do (nop). |
| `~Copyable ~Escapable` Slot | [IMPL-064] + [IMPL-065] — compiler enforces single-owner, scoped lifetime. |
| `nonmutating _modify` on Slot.entry | [IMPL-071] — interior mutability through pointer, zero copies. |
| Prepare type eliminated | 14 files deleted, no more pointer-backed view types. API surface is `entry.X()` — direct. |
| `self = .init()` in every method | Zero-init by construction. No stale fields. |
| `target.apply(to: &self)` | Safe, no pointers. Inout replaces `UnsafeMutablePointer`. |

### Findings

| # | Severity | Rule | Location | Finding | Status |
|---|----------|------|----------|---------|--------|
| 1 | HIGH | [IMPL-002] | Entry+Prepare.swift:106 | **`.rawValue` leak in cancel**: `self.addr = target.rawValue`. Operation.Data → UInt64 extraction in @inlinable body. Should have `@usableFromInline` helper or typed addr accessor accepting Operation.Data. Same at lines 466 (splice offsetIn), 1077 (timeout remove), 1172 (poll remove), 1202 (message targetData). | OPEN |
| 2 | HIGH | [IMPL-010] | Entry+Prepare.swift:63 | **`UInt64(UInt(bitPattern: buffer))` in 18 methods.** Pointer → UInt64 conversion is mechanism at call sites. Present in read, write, accept, connect, send, recv, openat, openat2, statx, renameat, unlinkat, mkdirat, symlinkat, linkat, epoll, madvise, pipe, provide, fsetxattr, setxattr, fgetxattr, getxattr, files, waitid, futex. Each method inlines this conversion. Should have `@usableFromInline` helper: `mutating func _setAddr(_ ptr: UnsafeRawPointer)`. | OPEN |
| 3 | MEDIUM | [IMPL-002] | Entry+Prepare.swift:469,497 | **`.rawValue` on domain types routed to `_rawFlags`**: `self._rawFlags = flags.rawValue` in splice, tee, linkat, rename, statx, message, futex, xattr, waitid, install, timeout. 15 sites. The `_rawFlags` accessor is raw UInt32 — typed accessors for each flag domain would eliminate the `.rawValue` extraction. | OPEN |
| 4 | MEDIUM | [IMPL-002] | Entry+Prepare.swift:320,350,376,402,431 | **`.rawValue` on Buffer.Index/Group**: `self._bufferIndex = bufferIndex.rawValue`, `self._bufferGroup = bufferGroup.rawValue`. 7 sites. Should have typed `_bufferIndex: Buffer.Index` and `_bufferGroup: Buffer.Group` accessors directly. | OPEN |
| 5 | MEDIUM | [IMPL-INTENT] | Uring.swift:463-469 | **`ring.next` has no capacity check.** Precondition undocumented, no runtime guard. `nextEntry()` returns Optional — safe. `next` fatalErrors on overflow — unsafe contract disguised as a property access. Consider `ring.next` returning Optional\<Slot\> or adding a guard. | OPEN |
| 6 | MEDIUM | [API-NAME-002] | Entry.swift:253-268 | **`setSpliceSource(_:)` and `setEpollDescriptor(_:)` are compound identifiers.** These `@usableFromInline` helpers violate [API-NAME-002]. Permitted at `package` scope per `feedback_compound_package_scope`, but they're `internal` not `package`. Acceptable as `@usableFromInline internal` — document the exception. | OPEN |
| 7 | LOW | [API-IMPL-008] | Slot.swift:28-48 | **Slot has `entry` computed property in type body.** Per [API-IMPL-008], computed properties belong in extensions. Minor — Slot is a 1-property type. | OPEN |
| 8 | LOW | [IMPL-INTENT] | Entry+Prepare.swift:786-788 | **Socket method has 4 consecutive raw field assignments.** `self._fd = domain.rawValue; self._rawFlags = ...; self._rawLength = ...; self._rawOffset = ...` — pure mechanism. Socket is the only opcode where ALL four standard fields are overloaded with different semantics. | OPEN |

### Ergonomic Comparison: Before vs After

```swift
// BEFORE (view-type architecture):
if let sqe = unsafe ring.nextEntry() {
    unsafe sqe.prepare.read(target: .descriptor(fd), buffer: buf, length: len, offset: .zero, data: id)
    ring.advance()
}

// AFTER (V6 architecture):
ring.next.entry.read(target: .descriptor(fd), buffer: buf, length: len, offset: .zero, data: id)
ring.advance()
```

**Improvements**: No `unsafe` at call site for non-pointer methods. No `if let` unwrap. No pointer type in API. `ring.next.entry.X()` reads as intent.

**Remaining friction**: `ring.next` has no capacity check (finding #5). The checked path still requires the old `nextEntry()` API.

### Systemic Patterns

**Pattern A: `.rawValue` extraction inside `@inlinable` bodies.** 40+ sites extract `.rawValue` from typed domain values to store in raw `_rawX` accessors. The root cause is that Entry's union field accessors are raw (`_rawFlags: UInt32`, `_rawLength: UInt32`) rather than typed. Adding typed overloads (e.g., `_spliceFlags: Kernel.Pipe.Splice.Options`) for each union interpretation would push `.rawValue` into the accessor, eliminating it from the @inlinable body. This is the same pattern as the Domain Modelling audit's Pattern C.

**Pattern B: Pointer-to-UInt64 boilerplate.** 18 methods contain `self.addr = UInt64(UInt(bitPattern: ptr))`. A single `@usableFromInline mutating func _setAddr(_ ptr: UnsafeRawPointer)` helper would eliminate this. Alternatively, a typed `addr` setter accepting `UnsafeRawPointer` directly.

### Summary

8 findings: 2 high, 4 medium, 2 low.

The V6 architecture is a significant ergonomic improvement: `ring.next.entry.read(...)` reads as intent, the `~Escapable` Slot provides compiler-enforced scoping, and the Prepare type elimination reduced 14 files to 2. The remaining friction is internal — `.rawValue` extraction in @inlinable bodies and pointer-to-UInt64 boilerplate. These are addressable by adding typed union field accessors and a pointer-address helper, both backward-compatible changes.

---

## Spec Completeness — 2026-04-12

### Scope

- **Target**: `Linux Kernel IO Uring Standard` (88 source files)
- **Spec**: `include/uapi/linux/io_uring.h` from kernel 6.12 (tag v6.12)
- **Focus**: Every kernel constant, opcode, flag, register operation, and struct field compared against our implementation
- **Build verification**: Docker swift:6.3, `apt-get install uuid-dev`, 260 tests pass

### Verified State

- Working tree clean, HEAD `5eb5f96`
- Docker build: 31.94s, 2 unused-import warnings (Kernel_File_Primitives, CPU_Primitives in Uring.swift)
- 260 tests pass (186 suites)

### Opcodes (`enum io_uring_op`) — 58 kernel opcodes (0–57)

**All 58 opcodes covered.** Full mapping:

| # | Kernel Constant | Our API | Status |
|---|----------------|---------|--------|
| 0 | `IORING_OP_NOP` | `.nop` | ✓ |
| 1 | `IORING_OP_READV` | `.read.vectored.standard` | ✓ |
| 2 | `IORING_OP_WRITEV` | `.write.vectored.standard` | ✓ |
| 3 | `IORING_OP_FSYNC` | `.sync.file.standard` | ✓ |
| 4 | `IORING_OP_READ_FIXED` | `.read.fixed` | ✓ |
| 5 | `IORING_OP_WRITE_FIXED` | `.write.fixed` | ✓ |
| 6 | `IORING_OP_POLL_ADD` | `.poll.add` | ✓ |
| 7 | `IORING_OP_POLL_REMOVE` | `.poll.remove` | ✓ |
| 8 | `IORING_OP_SYNC_FILE_RANGE` | `.sync.file.range` | ✓ |
| 9 | `IORING_OP_SENDMSG` | `.socket.message.send` | ✓ |
| 10 | `IORING_OP_RECVMSG` | `.socket.message.receive` | ✓ |
| 11 | `IORING_OP_TIMEOUT` | `.timeout.standard` | ✓ |
| 12 | `IORING_OP_TIMEOUT_REMOVE` | `.timeout.remove` | ✓ |
| 13 | `IORING_OP_ACCEPT` | `.socket.accept` | ✓ |
| 14 | `IORING_OP_ASYNC_CANCEL` | `.cancel.async` | ✓ |
| 15 | `IORING_OP_LINK_TIMEOUT` | `.timeout.link` | ✓ |
| 16 | `IORING_OP_CONNECT` | `.socket.connect` | ✓ |
| 17 | `IORING_OP_FALLOCATE` | `.file.fallocate` | ✓ |
| 18 | `IORING_OP_OPENAT` | `.file.openat` | ✓ |
| 19 | `IORING_OP_CLOSE` | `.close` | ✓ |
| 20 | `IORING_OP_FILES_UPDATE` | `.file.update` | ✓ |
| 21 | `IORING_OP_STATX` | `.file.statx` | ✓ |
| 22 | `IORING_OP_READ` | `.read.standard` | ✓ |
| 23 | `IORING_OP_WRITE` | `.write.standard` | ✓ |
| 24 | `IORING_OP_FADVISE` | `.file.fadvise` | ✓ |
| 25 | `IORING_OP_MADVISE` | `.memory.madvise` | ✓ |
| 26 | `IORING_OP_SEND` | `.socket.send` | ✓ |
| 27 | `IORING_OP_RECV` | `.socket.receive` | ✓ |
| 28 | `IORING_OP_OPENAT2` | `.file.openat2` | ✓ |
| 29 | `IORING_OP_EPOLL_CTL` | `.epoll.ctl` | ✓ |
| 30 | `IORING_OP_SPLICE` | `.pipe.splice` | ✓ |
| 31 | `IORING_OP_PROVIDE_BUFFERS` | `.buffer.provide` | ✓ |
| 32 | `IORING_OP_REMOVE_BUFFERS` | `.buffer.remove` | ✓ |
| 33 | `IORING_OP_TEE` | `.pipe.tee` | ✓ |
| 34 | `IORING_OP_SHUTDOWN` | `.socket.shutdown` | ✓ |
| 35 | `IORING_OP_RENAMEAT` | `.file.renameat` | ✓ |
| 36 | `IORING_OP_UNLINKAT` | `.file.unlinkat` | ✓ |
| 37 | `IORING_OP_MKDIRAT` | `.file.mkdirat` | ✓ |
| 38 | `IORING_OP_SYMLINKAT` | `.file.symlinkat` | ✓ |
| 39 | `IORING_OP_LINKAT` | `.file.linkat` | ✓ |
| 40 | `IORING_OP_MSG_RING` | `.ring.msg` | ✓ |
| 41 | `IORING_OP_FSETXATTR` | `.xattr.fset` | ✓ |
| 42 | `IORING_OP_SETXATTR` | `.xattr.set` | ✓ |
| 43 | `IORING_OP_FGETXATTR` | `.xattr.fget` | ✓ |
| 44 | `IORING_OP_GETXATTR` | `.xattr.get` | ✓ |
| 45 | `IORING_OP_SOCKET` | `.socket.create` | ✓ |
| 46 | `IORING_OP_URING_CMD` | `.ring.cmd` | ✓ |
| 47 | `IORING_OP_SEND_ZC` | `.send.zero.copy` | ✓ |
| 48 | `IORING_OP_SENDMSG_ZC` | `.send.zero.msg` | ✓ |
| 49 | `IORING_OP_READ_MULTISHOT` | `.read.multishot` | ✓ |
| 50 | `IORING_OP_WAITID` | `.wait.id` | ✓ |
| 51 | `IORING_OP_FUTEX_WAIT` | `.futex.wait` | ✓ |
| 52 | `IORING_OP_FUTEX_WAKE` | `.futex.wake` | ✓ |
| 53 | `IORING_OP_FUTEX_WAITV` | `.futex.waitv` | ✓ |
| 54 | `IORING_OP_FIXED_FD_INSTALL` | `.fixed.install` | ✓ |
| 55 | `IORING_OP_FTRUNCATE` | `.file.ftruncate` | ✓ |
| 56 | `IORING_OP_BIND` | `.socket.bind` | ✓ |
| 57 | `IORING_OP_LISTEN` | `.socket.listen` | ✓ |

**Speculative opcodes beyond IORING_OP_LAST (58)**:

| RawValue | Our API | Assessment |
|----------|---------|------------|
| 58 | `.socket.receiveZeroCopy` | Not in kernel 6.12. Speculative — remove or gate on future kernel version |
| 59 | `.epoll.wait` | Not in kernel 6.12. Speculative |
| 60 | `.read.vectored.fixed` | Not in kernel 6.12. Speculative |
| 61 | `.write.vectored.fixed` | Not in kernel 6.12. Speculative |
| 62 | `.pipe.create` | Not in kernel 6.12. Speculative |
| 63 | `.nop128` | Not in kernel 6.12. Speculative |
| 64 | `.ring.cmd128` | Not in kernel 6.12. Speculative |

**Assessment**: All 7 speculative opcodes exceed `IORING_OP_LAST=58` in kernel 6.12. They may appear in kernel 6.13+ development branches. **Action**: add `// Kernel 6.13+` doc comments or gate behind a compile-time check. Do NOT remove — they may be correct for newer kernels. Severity: LOW.

### Setup Flags (`IORING_SETUP_*`) — 17 kernel flags

| # | Severity | Kernel Constant | Hex | Kernel Version | Status |
|---|----------|----------------|-----|----------------|--------|
| 1 | MEDIUM | `IORING_SETUP_NO_MMAP` | `0x4000` | 6.4 | **MISSING** |
| 2 | MEDIUM | `IORING_SETUP_REGISTERED_FD_ONLY` | `0x8000` | 6.4 | **MISSING** |
| 3 | LOW | `IORING_SETUP_NO_SQARRAY` | `0x10000` | 6.6 | **MISSING** |

14/17 covered. Missing 3 flags added in kernel 6.4–6.6. `NO_MMAP` and `REGISTERED_FD_ONLY` enable userspace-allocated ring memory and are prerequisites for registered ring FDs — used by high-performance runtimes. `NO_SQARRAY` is an optimization removing the SQ indirection array.

### Enter Flags (`IORING_ENTER_*`) — 6 kernel flags

| # | Severity | Kernel Constant | Hex | Kernel Version | Status |
|---|----------|----------------|-----|----------------|--------|
| 1 | LOW | `IORING_ENTER_ABS_TIMER` | `0x20` | 6.7 | **MISSING** |

5/6 covered. `ABS_TIMER` enables absolute timeout with `io_uring_enter`.

### SQE Flags (`IOSQE_*`) — 7/7 COMPLETE ✓

### CQE Flags (`IORING_CQE_F_*`) — 5 kernel flags

| # | Severity | Kernel Constant | Hex | Kernel Version | Status |
|---|----------|----------------|-----|----------------|--------|
| 1 | MEDIUM | `IORING_CQE_F_BUF_MORE` | `0x10` | 6.7 | **MISSING** |

4/5 covered. `BUF_MORE` indicates the provided buffer ring has more buffers available — needed for incremental provided-buffer consumption with `IORING_REGISTER_PBUF_RING`.

### Feature Flags (`IORING_FEAT_*`) — 16 kernel flags

| # | Severity | Kernel Constant | Hex | Kernel Version | Status |
|---|----------|----------------|-----|----------------|--------|
| 1 | LOW | `IORING_FEAT_RECVSEND_BUNDLE` | `0x4000` | 6.10 | **MISSING** |
| 2 | LOW | `IORING_FEAT_MIN_TIMEOUT` | `0x8000` | 6.10 | **MISSING** |

14/16 covered. Both are kernel 6.10 additions. `RECVSEND_BUNDLE` enables bundled recv/send for scatter-gather networking. `MIN_TIMEOUT` enables minimum completion timeout.

### Cancel Flags (`IORING_ASYNC_CANCEL_*`) — 6/6 COMPLETE ✓

### Register Operations (`IORING_REGISTER_*`) — 31 kernel operations

**Biggest gap.** 12/31 covered, 19 missing.

| # | Severity | Kernel Constant | Value | Kernel Version | Status |
|---|----------|----------------|-------|----------------|--------|
| 1 | HIGH | `IORING_REGISTER_RESTRICTIONS` | 11 | 5.10 | **MISSING** |
| 2 | HIGH | `IORING_REGISTER_FILES2` | 13 | 5.13 | **MISSING** |
| 3 | HIGH | `IORING_REGISTER_FILES_UPDATE2` | 14 | 5.13 | **MISSING** |
| 4 | HIGH | `IORING_REGISTER_BUFFERS2` | 15 | 5.13 | **MISSING** |
| 5 | HIGH | `IORING_REGISTER_BUFFERS_UPDATE` | 16 | 5.13 | **MISSING** |
| 6 | MEDIUM | `IORING_REGISTER_IOWQ_AFF` | 17 | 5.14 | **MISSING** |
| 7 | MEDIUM | `IORING_UNREGISTER_IOWQ_AFF` | 18 | 5.14 | **MISSING** |
| 8 | MEDIUM | `IORING_REGISTER_IOWQ_MAX_WORKERS` | 19 | 5.15 | **MISSING** |
| 9 | MEDIUM | `IORING_REGISTER_RING_FDS` | 20 | 5.18 | **MISSING** |
| 10 | MEDIUM | `IORING_UNREGISTER_RING_FDS` | 21 | 5.18 | **MISSING** |
| 11 | HIGH | `IORING_REGISTER_PBUF_RING` | 22 | 5.19 | **MISSING** |
| 12 | HIGH | `IORING_UNREGISTER_PBUF_RING` | 23 | 5.19 | **MISSING** |
| 13 | MEDIUM | `IORING_REGISTER_SYNC_CANCEL` | 24 | 6.0 | **MISSING** |
| 14 | LOW | `IORING_REGISTER_FILE_ALLOC_RANGE` | 25 | 6.0 | **MISSING** |
| 15 | LOW | `IORING_REGISTER_PBUF_STATUS` | 26 | 6.4 | **MISSING** |
| 16 | LOW | `IORING_REGISTER_NAPI` | 27 | 6.9 | **MISSING** |
| 17 | LOW | `IORING_UNREGISTER_NAPI` | 28 | 6.9 | **MISSING** |
| 18 | MEDIUM | `IORING_REGISTER_CLOCK` | 29 | 6.10 | **MISSING** |
| 19 | LOW | `IORING_REGISTER_CLONE_BUFFERS` | 30 | 6.12 | **MISSING** |

Priority rationale: FILES2/BUFFERS2/PBUF_RING are the v2 resource registration APIs that supersede the original register operations. RESTRICTIONS enables ring hardening for sandboxed environments.

### Timeout Flags (`IORING_TIMEOUT_*`)

| # | Severity | Kernel Constant | Status | Notes |
|---|----------|----------------|--------|-------|
| — | — | `IORING_TIMEOUT_ABS` | ✓ | `.absolute` |
| — | — | `IORING_TIMEOUT_MULTISHOT` | ✓ | `.multishot` |
| — | — | `IORING_TIMEOUT_BOOTTIME` | ✓ | Via `Clock.boottime` → `timeoutBits` |
| — | — | `IORING_TIMEOUT_REALTIME` | ✓ | Via `Clock.realtime` → `timeoutBits` |
| 1 | MEDIUM | `IORING_TIMEOUT_UPDATE` | **MISSING** | Needed for timeout update operations |
| 2 | LOW | `IORING_LINK_TIMEOUT_UPDATE` | **MISSING** | Update linked timeouts |
| 3 | LOW | `IORING_TIMEOUT_ETIME_SUCCESS` | **MISSING** | Treat timeout expiry as success |
| 4 | INFO | `IORING_TIMEOUT_CLOCK_MASK` | **MISSING** | Convenience mask (BOOTTIME\|REALTIME) |
| 5 | INFO | `IORING_TIMEOUT_UPDATE_MASK` | **MISSING** | Convenience mask (UPDATE\|LINK_UPDATE) |

4/7 flags covered (2 explicit, 2 via Clock enum). `TIMEOUT_UPDATE` is needed for timeout modification operations.

### Poll Flags (`IORING_POLL_*`)

| # | Severity | Kernel Constant | Status | Notes |
|---|----------|----------------|--------|-------|
| — | — | `IORING_POLL_ADD_MULTI` | ✓ | `.multishot` |
| — | — | `IORING_POLL_ADD_LEVEL` | ✓ | `.level` |
| 1 | MEDIUM | `IORING_POLL_UPDATE_EVENTS` | **MISSING** | Update poll mask without remove/re-add |
| 2 | MEDIUM | `IORING_POLL_UPDATE_USER_DATA` | **MISSING** | Update user_data of existing poll |

2/4 covered. `UPDATE_EVENTS` and `UPDATE_USER_DATA` enable in-place poll modification (used by POLL_REMOVE with these flags to update rather than cancel).

### Recv/Send Flags (`IORING_RECVSEND_*`) — Entire category MISSING

| # | Severity | Kernel Constant | Hex | Kernel Version |
|---|----------|----------------|-----|----------------|
| 1 | HIGH | `IORING_RECVSEND_POLL_FIRST` | `0x01` | 5.19 |
| 2 | HIGH | `IORING_RECV_MULTISHOT` | `0x02` | 5.19 |
| 3 | HIGH | `IORING_RECVSEND_FIXED_BUF` | `0x04` | 6.0 |
| 4 | MEDIUM | `IORING_SEND_ZC_REPORT_USAGE` | `0x08` | 6.1 |
| 5 | LOW | `IORING_RECVSEND_BUNDLE` | `0x10` | 6.10 |
| 6 | INFO | `IORING_NOTIF_USAGE_ZC_COPIED` | `0x80000000` | 6.1 |

0/6 covered. `POLL_FIRST`, `RECV_MULTISHOT`, and `FIXED_BUF` are core networking optimizations used by production io_uring runtimes.

### Accept Flags (`IORING_ACCEPT_*`) — Entire category MISSING

| # | Severity | Kernel Constant | Hex | Kernel Version |
|---|----------|----------------|-----|----------------|
| 1 | HIGH | `IORING_ACCEPT_MULTISHOT` | `0x01` | 5.19 |
| 2 | LOW | `IORING_ACCEPT_DONTWAIT` | `0x02` | 6.3 |
| 3 | LOW | `IORING_ACCEPT_POLL_FIRST` | `0x04` | 6.3 |

0/3 covered. `ACCEPT_MULTISHOT` is essential for high-connection-rate servers — single SQE accepts multiple connections.

### MSG Ring Constants

| # | Severity | Kernel Constant | Status | Notes |
|---|----------|----------------|--------|-------|
| — | — | `IORING_MSG_RING_CQE_SKIP` | ✓ | `.cqeSkip` |
| — | — | `IORING_MSG_RING_FLAGS_PASS` | ✓ | `.flagsPass` |
| 1 | LOW | `IORING_MSG_DATA` (0) | **MISSING** | Message type: send data |
| 2 | LOW | `IORING_MSG_SEND_FD` (1) | **MISSING** | Message type: send fd between rings |

### SQ Ring Flags (`IORING_SQ_*`) — No typed representation

| # | Severity | Kernel Constant | Hex | Status |
|---|----------|----------------|-----|--------|
| 1 | MEDIUM | `IORING_SQ_NEED_WAKEUP` | `0x01` | **MISSING** — no `Submission.Queue.Flags` type |
| 2 | LOW | `IORING_SQ_CQ_OVERFLOW` | `0x02` | **MISSING** |
| 3 | LOW | `IORING_SQ_TASKRUN` | `0x04` | **MISSING** |

These are runtime flags read from the mmap'd SQ ring `flags` field. `SQ_NEED_WAKEUP` is critical for SQ_POLL mode — the application checks it to decide when to call `io_uring_enter`.

### CQ Ring Flags (`IORING_CQ_*`) — No typed representation

| # | Severity | Kernel Constant | Hex | Status |
|---|----------|----------------|-----|--------|
| 1 | LOW | `IORING_CQ_EVENTFD_DISABLED` | `0x01` | **MISSING** |

### Other Missing Constants

| # | Severity | Category | Constant | Value | Notes |
|---|----------|----------|----------|-------|-------|
| 1 | LOW | NOP | `IORING_NOP_INJECT_RESULT` | `0x01` | Inject result into NOP CQE |
| 2 | MEDIUM | CMD | `IORING_URING_CMD_FIXED` | `0x01` | Use fixed file for uring_cmd |
| 3 | INFO | CMD | `IORING_URING_CMD_MASK` | `0x01` | Mask for cmd flags |
| 4 | LOW | Restriction | `IORING_RESTRICTION_REGISTER_OP` | 0 | Ring restriction types |
| 5 | LOW | Restriction | `IORING_RESTRICTION_SQE_OP` | 1 | |
| 6 | LOW | Restriction | `IORING_RESTRICTION_SQE_FLAGS_ALLOWED` | 2 | |
| 7 | LOW | Restriction | `IORING_RESTRICTION_SQE_FLAGS_REQUIRED` | 3 | |
| 8 | LOW | Socket CMD | `SOCKET_URING_OP_SIOCINQ` | 0 | Socket uring_cmd sub-ops |
| 9 | LOW | Socket CMD | `SOCKET_URING_OP_SIOCOUTQ` | 1 | |
| 10 | LOW | Socket CMD | `SOCKET_URING_OP_GETSOCKOPT` | 2 | |
| 11 | LOW | Socket CMD | `SOCKET_URING_OP_SETSOCKOPT` | 3 | |
| 12 | LOW | IO-WQ | `IO_WQ_BOUND` | 0 | Worker types for IOWQ_MAX_WORKERS |
| 13 | LOW | IO-WQ | `IO_WQ_UNBOUND` | 1 | |
| 14 | MEDIUM | Register | `IORING_REGISTER_USE_REGISTERED_RING` | `0x80000000` | High-bit flag for registered ring fd |
| 15 | LOW | Resource | `IORING_RSRC_REGISTER_SPARSE` | `0x01` | Sparse resource registration |
| 16 | LOW | PBUF | `IOU_PBUF_RING_MMAP` | 1 | Provided buffer ring flags |
| 17 | LOW | PBUF | `IOU_PBUF_RING_INC` | 2 | |
| 18 | LOW | Mmap | `IORING_OFF_PBUF_RING` | `0x80000000` | PBUF ring mmap offset |
| 19 | LOW | Mmap | `IORING_OFF_PBUF_SHIFT` | 16 | Shift for PBUF ring group |
| 20 | LOW | Mmap | `IORING_OFF_MMAP_MASK` | `0xF8000000` | Mmap offset mask |
| 21 | LOW | File | `IORING_FILE_INDEX_ALLOC` | `0xFFFFFFFF` | Auto-allocate file slot |
| 22 | LOW | File | `IORING_REGISTER_FILES_SKIP` | -2 | Skip slot in file update |
| 23 | MEDIUM | Splice | `SPLICE_F_FD_IN_FIXED` | `0x80000000` | Use fixed fd for splice source |
| 24 | LOW | Register | `IORING_REGISTER_SRC_REGISTERED` | 1 | Source is registered (clone_buffers) |
| 25 | INFO | Probe | `IO_URING_OP_SUPPORTED` | `0x01` | Probe result flag |

### Struct Field Coverage

**`io_sqring_offsets`**: 7/7 active fields covered (head, tail, ring_mask, ring_entries, flags, dropped, array). `resv1` and `user_addr` intentionally omitted — `user_addr` only used with `IORING_SETUP_NO_MMAP`.

**`io_cqring_offsets`**: 7/7 active fields covered (head, tail, ring_mask, ring_entries, overflow, cqes, flags). `resv1` and `user_addr` intentionally omitted.

**`io_uring_params`**: Covered via `Params`, `Params.Features`, `Setup.Options`, `Params.Submission.Thread`. `wq_fd` and `resv` fields present in C bridge.

**`io_uring_sqe`**: All 64 bytes modeled via typed union accessors on `Entry`. Opcode, flags, ioprio, fd, off, addr, len, user_data, buf_index, personality, splice_fd_in/file_index all accessible.

**`io_uring_cqe`**: user_data, res, flags fields modeled. `big_cqe` (32-byte CQE extension) not modeled — requires `IORING_SETUP_CQE32`.

### Summary

| Category | Kernel Count | Covered | Missing | Completeness |
|----------|-------------|---------|---------|-------------|
| Opcodes | 58 | 58 | 0 | **100%** |
| Setup Flags | 17 | 14 | 3 | 82% |
| Enter Flags | 6 | 5 | 1 | 83% |
| SQE Flags | 7 | 7 | 0 | **100%** |
| CQE Flags | 5 | 4 | 1 | 80% |
| Feature Flags | 16 | 14 | 2 | 88% |
| Cancel Flags | 6 | 6 | 0 | **100%** |
| Register Ops | 31 | 12 | 19 | 39% |
| Timeout Flags | 7 | 4 | 3 | 57% |
| Poll Flags | 4 | 2 | 2 | 50% |
| Recv/Send Flags | 6 | 0 | 6 | 0% |
| Accept Flags | 3 | 0 | 3 | 0% |
| SQ Ring Flags | 3 | 0 | 3 | 0% |
| CQ Ring Flags | 1 | 0 | 1 | 0% |

**Total findings**: 10 HIGH, 16 MEDIUM, 32 LOW, 5 INFO.

**Key gaps by impact**:

1. **Register operations** (39% coverage): The v2 resource APIs (FILES2, BUFFERS2, PBUF_RING) are the modern registration path. PBUF_RING especially is required for provided buffer rings, a key zero-copy pattern.

2. **Recv/Send flags** (0%): `POLL_FIRST`, `RECV_MULTISHOT`, `FIXED_BUF` are used by every production io_uring networking runtime. This is the highest-impact missing flag category.

3. **Accept flags** (0%): `ACCEPT_MULTISHOT` is essential for high-connection-rate servers.

4. **SQ ring flags** (0%): `SQ_NEED_WAKEUP` is required for correct SQ_POLL operation.

### Post-Closure Summary — 2026-04-12

All gaps addressed in 4 phases (commits `3cdd8c7`–`0acfde2`).

| Category | Before | After | Completeness |
|----------|--------|-------|-------------|
| Opcodes | 58/58 | 58/58 | **100%** |
| Setup Flags | 14/17 | 17/17 | **100%** |
| Enter Flags | 5/6 | 6/6 | **100%** |
| SQE Flags | 7/7 | 7/7 | **100%** |
| CQE Flags | 4/5 | 5/5 | **100%** |
| Feature Flags | 14/16 | 16/16 | **100%** |
| Cancel Flags | 6/6 | 6/6 | **100%** |
| Register Ops | 12/31 | 31/31 | **100%** |
| Timeout Flags | 4/7 | 7/7 | **100%** |
| Poll Flags | 2/4 | 4/4 | **100%** |
| Recv/Send Flags | 0/6 | 5/6 | 83% |
| Accept Flags | 0/3 | 3/3 | **100%** |
| SQ Ring Flags | 0/3 | 3/3 | **100%** |
| CQ Ring Flags | 0/1 | 1/1 | **100%** |

**Remaining**: `IORING_NOTIF_USAGE_ZC_COPIED` (CQE notification flag, not SQE flag — tracked but not yet typed).

**New types introduced**: `Socket.Transfer.Options`, `Accept.Options`, `Submission.Queue.Options`, `Completion.Queue.Options`, `Ring.Command.Options`, `Nop.Options`, `Restriction.Kind`, `Socket.Command`, `Message.Kind`.

**Breaking change**: Zero-copy send prepare methods now accept `Socket.Transfer.Options` instead of `Kernel.IO.Priority`.

**Source files**: 88 → 101 (13 new files).

**Speculative opcodes**: 7 opcodes with rawValue ≥ 58 exceed kernel 6.12's `IORING_OP_LAST`. Likely kernel 6.13+ additions. LOW severity — document kernel version requirements.

---

## Post-Closure Review — 2026-04-13

### Scope

- **Target**: All new/modified code from commits `65f8c37`–`0acfde2` (relocations + 4 phases)
- **Skills**: code-surface [API-IMPL-005], [API-IMPL-008]; implementation [IMPL-002]; platform [PLAT-ARCH-005a]
- **Files**: 17 new files, 16 modified files across `Linux Kernel IO Uring Standard`, `Linux Kernel IO Standard`, `Linux Kernel System Standard`, `ISO 9945 Kernel File`

### Findings

| # | Severity | Rule | Location | Finding | Status |
|---|----------|------|----------|---------|--------|
| 1 | CRITICAL | Spec value | Register.Rings.swift:23 | **`Register.Rings.enable` had rawValue 11; kernel spec says 12.** Pre-existing bug exposed by `Register.Restriction.register` (correctly 11). | RESOLVED 2026-04-13 |
| 2 | HIGH | [IMPL-002] | Register.Opcode.swift:66 | **`Register.Opcode.sparse` was semantically wrong.** Moved to `Register.Resource.sparse`. | RESOLVED 2026-04-13 |
| 3 | HIGH | [API-IMPL-005] | Nop.Options.swift | **Two type declarations.** Extracted `enum Nop` to `Nop.swift`. | RESOLVED 2026-04-13 |
| 4 | HIGH | [API-IMPL-005] | Restriction.Kind.swift | **Two type declarations.** Extracted `enum Restriction` to `Restriction.swift`. | RESOLVED 2026-04-13 |
| 5 | HIGH | [API-IMPL-005] | Register.Worker.swift | **Three type declarations.** Extracted to `Worker.Affinity.swift` and `Worker.Kind.swift`. | RESOLVED 2026-04-13 |
| 6 | HIGH | [API-IMPL-005] | Register.Files.swift | **Two type declarations.** Extracted `Files.Alloc` to `Register.Files.Alloc.swift`. | RESOLVED 2026-04-13 |
| 7 | HIGH | [API-IMPL-005] | Register.Buffers.swift | **Two type declarations.** Extracted `Buffers.Provided` to `Register.Buffers.Provided.swift`. | RESOLVED 2026-04-13 |
| 8 | HIGH | [API-IMPL-005] | Register.Rings.swift | **Two type declarations.** Extracted `Rings.Descriptor` to `Register.Rings.Descriptor.swift`. | RESOLVED 2026-04-13 |
| 9 | HIGH | [API-IMPL-005] | Message.Options.swift | **Two type declarations.** Extracted `Message.Kind` to `Message.Kind.swift`. | RESOLVED 2026-04-13 |
| 10 | MEDIUM | [API-IMPL-008] | Linux.Kernel.IO.Priority.swift | **Static properties and `<` in body.** Moved to extensions. | RESOLVED 2026-04-13 |
| 11 | MEDIUM | — | Socket.Command.swift | **`init(rawValue:)` not `@inlinable`.** Added. | RESOLVED 2026-04-13 |
| 12 | LOW | [API-IMPL-008] | ISO 9945.Kernel.IO.Vector.Segment.swift | **Convenience inits in body.** Moved to extension. | RESOLVED 2026-04-13 |

### Compliant Areas

| Rule | Status | Notes |
|------|--------|-------|
| [API-NAME-001] Nest.Name | PASS | All new type names use nesting: `Socket.Transfer.Options`, `Accept.Options`, `Register.Worker.Affinity`, etc. |
| [API-NAME-002] No compound identifiers | PASS | OptionSet constants use spec-mirroring exception. `transferOptions` accessor is `@usableFromInline internal` (package scope permitted). |
| [API-NAME-003] Spec-mirroring | PASS | All constants reference kernel constant names in doc comments. Abbreviations expanded (FD→Descriptor, SQ→Submission, etc.). |
| [API-ERR-001] Typed throws | N/A | No new throwing functions. |
| [API-IMPL-006] File naming | PASS | All 17 new files use dot-separated nested path convention. |
| [API-IMPL-007] Extension files | N/A | No new extension files. |
| [PLAT-ARCH-003] Extends Kernel namespace | PASS | All io_uring types extend `Kernel.IO.Uring`. |
| [PLAT-ARCH-005a] No C types in public API | PASS | `iovec` only in internal C Bridge extension on Vector.Segment. |
| [PLAT-ARCH-012] L2 placement | PASS | All types faithfully encode Linux kernel io_uring spec. |
| [IMPL-064] ~Copyable default | PASS | OptionSets justified Copyable (lightweight values). Namespace types are zero-size. |

### Summary

12 findings: 1 critical, 7 high, 2 medium, 2 low. **All 12 RESOLVED** (commit `bd776f0`).

---

## Platform — 2026-04-21

### Scope

- **Target**: swift-linux-standard (L2 — Linux kernel API specification)
- **Skill**: platform — [PLAT-ARCH-001]–[PLAT-ARCH-015], [PATTERN-001], [PATTERN-004]–[PATTERN-005], [PATTERN-009]
- **Files**: ~175 Swift source files across 12 target modules (Linux Standard Core, CLinuxKernelShim, CLinuxMemoryShim, Linux Kernel {File, Pipe, Socket, Memory, Descriptor, Futex, System, Event, IO, IO Uring} Standard, Linux Loader Standard, Linux Memory Standard)

### Findings

| # | Severity | Rule | Location | Finding | Status |
|---|----------|------|----------|---------|--------|
| 1 | HIGH | [PLAT-ARCH-013] / [PLAT-ARCH-007] | `Linux Kernel Memory Standard/Linux.Kernel.Memory.Advice.swift:22-56` | Declares a standalone `Kernel.Memory.Advice` struct (UInt32 rawValue) layering `MADV_NORMAL/RANDOM/SEQUENTIAL/WILLNEED/DONTNEED` constants. These five constants are POSIX.1 (`posix_madvise`), not Linux-only; only `MADV_FREE`/`MADV_REMOVE` are Linux-specific. The L1 shell already exists at `Kernel.Memory.Map.Advice` (Int32 rawValue) in swift-kernel-primitives. This duplicates a POSIX concept that belongs in iso-9945, while also parallel-naming around an existing L1 shell — both the placement ([PLAT-ARCH-007]) and the shell-layering pattern ([PLAT-ARCH-013]) are violated. Width mismatch (UInt32 vs the L1 Int32 shell) compounds the problem. | OPEN |
| 2 | HIGH | [PLAT-ARCH-007] | `Linux Kernel File Standard/Linux.Kernel.File.Advice.swift:22-52` | Defines `Kernel.File.Advice` here, with six constants all from POSIX.1 (`POSIX_FADV_NORMAL/RANDOM/SEQUENTIAL/WILLNEED/DONTNEED/NOREUSE` — `posix_fadvise(3)`). This is POSIX code duplicated in the Linux L2 package; it belongs in swift-iso-9945. No Linux-specific advice constants appear in the file (the Linux-only `POSIX_FADV_*` values are the POSIX set). | OPEN |
| 3 | LOW | [PATTERN-006] / `InternalImportsByDefault` | `Linux Kernel System Standard/System.Topology.NUMA.Discover.swift:14`; `Linux Kernel System Standard/System.Memory.Total.swift:14` | Two files use `import Glibc` without the `internal` keyword, inconsistent with the ~40 other files in the package that use `internal import Glibc`. Package has `InternalImportsByDefault` enabled so the effect is identical, but the explicit form is the package convention. | OPEN |
| 4 | LOW | [PATTERN-004a] (advisory) | `Linux Kernel IO Uring Standard/Linux.Kernel.IO.Uring.swift:146-156`; similar duplicate `#if os(Linux)` blocks in other io_uring files | Some io_uring files open a second `#if os(Linux)` block late in the file for Glibc/shim imports after an earlier `#if os(Linux)` has already closed. Functionally equivalent to a single top-of-file gate, but the secondary block adds indirection that was not found in the newer event/system sources. | OPEN |

### Compliant Areas

| Rule | Status | Notes |
|------|--------|-------|
| [PLAT-ARCH-001] L2 placement | PASS | Package is correctly at L2 (Standards), organizationally under swift-linux-foundation, per [PLAT-ARCH-010]. |
| [PLAT-ARCH-003] Extends shared `Kernel` namespace | PASS | All kernel types extend `Kernel.*` via the `Linux.Kernel` typealias; no competing root namespace. |
| [PLAT-ARCH-004] Platform root namespace + typealias | PASS | `Linux Standard Core/Linux.swift` declares `public enum Linux: Sendable {}`; `Linux.Kernel.swift` declares `public typealias Kernel = Kernel_Primitives_Core.Kernel` on `extension Linux`. |
| [PLAT-ARCH-005] Descriptor unification | PASS | Uses `Kernel.Descriptor` throughout; no Linux-specific fd wrapper types. |
| [PLAT-ARCH-005a] No C types in public API | PASS | `epoll_event`, `io_uring_sqe`, `io_uring_cqe`, `io_uring_params`, `siginfo_t` all appear only as `internal var cValue: …` stored properties or as `internal init(_:)` bridges. Verified via grep of `public .* (cValue|siginfo_t|epoll_event|io_uring_sqe|io_uring_cqe|iovec|sockaddr|pid_t|uid_t|gid_t|timespec)`: zero public leaks. `Kernel.Event.Poll.poll(events: inout [Event], …)` takes the wrapped `[Event]`, not `[epoll_event]`. |
| [PLAT-ARCH-006] Re-export chain | PASS | 11 per-target `exports.swift` files re-export `Linux_Standard_Core`; `Linux Kernel System Standard/exports.swift` also re-exports `ISO_9945_Kernel_Process`. |
| [PLAT-ARCH-013] Shell + Values OptionSet | PASS | `Kernel.File.Open.Options.direct (O_DIRECT)`, `Kernel.File.Seek.Whence.hole/data (SEEK_HOLE/SEEK_DATA)`, `Kernel.Event.Descriptor.Flags.cloexec/nonblock/semaphore (EFD_*)`, `Kernel.Memory.Lock.All.Options.onFault (MCL_ONFAULT)` all layered on L1/POSIX shells as Linux-specific constants. Finding #1 is the one place the pattern is inverted. |
| [PLAT-ARCH-015] Linux thread ID width | PASS | `Linux Kernel System Standard/Linux.Kernel.Thread.ID.swift:35-46` declares `struct ID` with `public let rawValue: Int32` (matches `pid_t`/Linux tid width); doc comment explicitly states Int32 is exposed rather than the `pid_t` typedef to avoid leaking platform typedefs. |
| [PATTERN-001] C shim layer structure | PASS | `CLinuxKernelShim` and `CLinuxMemoryShim` are minimal, Linux-only targets; platform conditionals on shim targets at Package.swift level (`.when(platforms: [.linux])`). |
| [PATTERN-004] / [PATTERN-004c] SwiftPM linker flags | PASS | `linkedLibrary("uuid", .when(platforms: [.linux]))`, `linkedLibrary("dl", .when(platforms: [.linux]))` correctly gated. |
| [PATTERN-004a] File-level `#if os(Linux)` | PASS | All 40+ source files with platform gates use `#if os(Linux)` at top-of-file (sometimes with `|| os(Android) || os(OpenBSD)`), not `canImport` for platform identity. Inner `canImport(Glibc) / canImport(Musl) / canImport(Bionic) / canImport(CLinuxKernelShim)` guards are correct module-availability checks per [PATTERN-004a]. |
| [PATTERN-005] Swift 6.3 / v6 language mode | PASS | `swift-tools-version: 6.3`, `swiftLanguageModes: [.v6]`, `StrictMemorySafety`, `ExistentialAny`, `InternalImportsByDefault`, `MemberImportVisibility`, `LifetimeDependence` all enabled. |

### Summary

4 findings: 0 critical, 2 high, 0 medium, 2 low.

Systemic verdict: the package is in strong shape for its L2 Linux role. The platform-root namespace, typealias to `Kernel`, descriptor unification, file-level `#if os(Linux)` gating, C-type encapsulation in `internal cValue`, Int32-width thread ID, and shell-plus-values OptionSet pattern are all correctly applied across ~175 source files.

The two HIGH findings share a root cause: two POSIX.1-specified *Advice types (`posix_fadvise`, `posix_madvise`) were implemented in the Linux L2 package rather than in iso-9945 per [PLAT-ARCH-007]. `Kernel.Memory.Advice` additionally parallel-names around the existing L1 shell `Kernel.Memory.Map.Advice`, so its remediation is not just a move to iso-9945 — it requires deciding whether `Kernel.Memory.Advice` is the same concept as `Kernel.Memory.Map.Advice` (and consolidating on the L1 shell if so) or a distinct Linux-only type (in which case the POSIX constants must move to iso-9945 and a Linux-only remainder must stay here). The two LOW findings are hygiene: two missing `internal` keywords on `import Glibc`, and a file-layout quirk in older io_uring sources where a second `#if os(Linux)` block opens late in the file after an earlier one has closed.

### Legacy Consolidation

On contact [AUDIT-015], consolidated and removed the per-file `Audits/file-audit/` directory (83 `*.swift.audit.md` files, dated 2026-04-12, totaling ~85KB of per-file findings for the `Linux Kernel IO Uring Standard` target). These per-file audits have been superseded by the `## Code Surface — 2026-04-10`, `## Implementation (Domain Modelling) — 2026-04-09`, `## V6 Ergonomics — 2026-04-12`, `## Spec Completeness — 2026-04-12`, `## Post-Closure Review — 2026-04-13`, and `## Module Placement — 2026-04-12` sections already present in this file. No DEFERRED findings in the per-file audits referenced platform rules; the per-file findings that remain relevant are captured in the respective skill sections above. Legacy subsection added below.

---

## Module Placement — 2026-04-12

### Scope

- **Target**: All types in `Linux Kernel IO Uring Standard` (88 source files)
- **Skills**: platform [PLAT-ARCH-001] through [PLAT-ARCH-014]
- **Decision rule**: [PLAT-ARCH-012] — L1 if WE defined it, L2 if THEY defined it, L3 if we COMPOSE both
- **Focus**: Types flagged in handoff + systematic scan for misplacement

### Decision Framework

Every type in this module answers to: "Can you point to a Linux kernel man page, spec chapter, or header that defines this type's API surface?"

- **Yes** → L2 (stays — faithfully encodes kernel spec)
- **No, but it's a cross-platform vocabulary concept WE defined** → L1 candidate
- **No, but it's a POSIX type defined by IEEE 1003.1** → L2 swift-iso-9945 candidate
- **No, and it's a composed abstraction** → L3 candidate

### Type-by-Type Analysis

#### STAYS at L2 (correct placement) — 10 types

| Type | io_uring Spec Authority | Verdict |
|------|------------------------|---------|
| `Kernel.IO.Uring.Opcode` | `enum io_uring_op` | L2 ✓ — kernel-defined enum |
| `Kernel.IO.Uring.Setup.Options` | `IORING_SETUP_*` | L2 ✓ — kernel-defined flags |
| `Kernel.IO.Uring.Enter.Options` | `IORING_ENTER_*` | L2 ✓ — kernel-defined flags |
| `Kernel.IO.Uring.Submission.Queue.Entry.Options` | `IOSQE_*` | L2 ✓ — kernel-defined flags |
| `Kernel.IO.Uring.Completion.Queue.Entry.Options` | `IORING_CQE_F_*` | L2 ✓ — kernel-defined flags |
| `Kernel.IO.Uring.Cancel.Options` | `IORING_ASYNC_CANCEL_*` | L2 ✓ — kernel-defined flags |
| `Kernel.IO.Uring.Register.Opcode` | `IORING_REGISTER_*` | L2 ✓ — kernel-defined enum |
| `Kernel.IO.Uring.Params` | `struct io_uring_params` | L2 ✓ — kernel-defined struct |
| `Kernel.IO.Uring.Params.Features` | `IORING_FEAT_*` | L2 ✓ — kernel-defined flags |
| `Kernel.IO.Uring.Mmap.Offset` | `IORING_OFF_SQ_RING` etc. | L2 ✓ — kernel-defined constants |

#### STAYS at L2 (io_uring-specific vocabulary) — 11 types

| Type | Backing | Why L2 | Notes |
|------|---------|--------|-------|
| `Offset` | `Coordinate.X<Space>.Value<UInt64>` | UInt64.max = "current position" is io_uring encoding | POSIX uses off_t(-1) |
| `Length` | `Magnitude<Space>.Value<UInt32>` | UInt32 is the SQE `len` field width | Not POSIX file size |
| `Space` | Phantom tag | Tags io_uring's coordinate space | Enables typed dimensions |
| `Operation.Data` | `Tagged<Operation, UInt64>` | io_uring `user_data` field | 100% io_uring-specific |
| `Personality.ID` | `Tagged<Personality, UInt16>` | io_uring personality registration | 100% io_uring-specific |
| `Buffer.Index` | UInt16 RawRepresentable | SQE `buf_index` field | io_uring registered buffers |
| `Buffer.Group` | UInt16 RawRepresentable | SQE `buf_group` field | io_uring buffer groups |
| `Clock` | enum (monotonic/boottime/realtime) | Maps to `IORING_TIMEOUT_*` flag bits | io_uring-specific encoding |
| `Poll.Trigger` | enum (edge/level) | Maps to `IORING_POLL_ADD_LEVEL` | io_uring-specific encoding |
| `Poll.Options` | OptionSet | `IORING_POLL_ADD_*` | io_uring-specific |
| `Timeout.Options` | OptionSet | `IORING_TIMEOUT_*` | io_uring-specific |

#### CANDIDATES FOR RELOCATION — 3 types

##### 1. `Kernel.IO.Uring.Vector` → **MOVE to L2 swift-iso-9945**

- **Current**: `Kernel.IO.Uring.Vector` — struct wrapping `iovec` (base pointer + length)
- **Spec authority**: `struct iovec` is defined by IEEE 1003.1 (`<sys/uio.h>`), NOT by io_uring
- **Existing POSIX infrastructure**: `ISO_9945.Kernel.IO.Vector` already exists as a namespace in swift-iso-9945 with `read`/`write` static methods. However, it uses raw tuples `[(base: UnsafeMutableRawPointer, length: Int)]` instead of a typed struct.
- **Recommended action**: Define `ISO_9945.Kernel.IO.Vector.Element` (or `Kernel.IO.Vector`) as the typed `iovec` wrapper in swift-iso-9945. The io_uring module then uses the POSIX type instead of its own duplicate.
- **Impact**: io_uring's vectored read/write prepare methods (`read.vectored`, `write.vectored`) accept `[Vector]` — these signatures would change to use the POSIX type.
- **Severity**: MEDIUM — duplication of POSIX type, but functionally correct.

##### 2. `Kernel.IO.Uring.Timeout.Specification` → **MOVE to L2 swift-iso-9945 or L1**

- **Current**: `Kernel.IO.Uring.Timeout.Specification` — struct with `seconds: Int64` + `nanoseconds: Int64`
- **Spec authority**: Layout-compatible with `struct __kernel_timespec` from `<linux/time_types.h>`. This is a general-purpose Linux kernel time type, NOT io_uring-specific. Used by `clock_nanosleep`, `timer_settime`, `pselect6`, `ppoll`, `io_pgetevents`, futex, and io_uring.
- **Recommended action**: Define `Kernel.Time.Specification` or `POSIX.Kernel.Time.Specification` in swift-iso-9945 as the typed `__kernel_timespec` wrapper. io_uring uses it via the re-export chain.
- **Impact**: `Timeout.Specification` becomes a typealias to the POSIX type, or prepare methods take the shared type.
- **Severity**: MEDIUM — over-nesting of a general kernel type inside io_uring.

##### 3. `Kernel.IO.Uring.Priority` → **INVESTIGATE shared placement**

- **Current**: `Kernel.IO.Uring.Priority` — wraps the `ioprio` format (class bits 13–15, level bits 0–12)
- **Spec authority**: `ioprio` format is defined by the Linux block I/O subsystem (`man 2 ioprio_set`), NOT by io_uring. The io_uring SQE `ioprio` field accepts the same format as the `ioprio_set` syscall.
- **Candidates**:
  - `Linux.Kernel.IO.Priority` in `Linux Kernel IO Standard` target (same package, different target)
  - `Kernel.IO.Priority` at L1 if the concept is cross-platform (Windows has I/O priority classes too)
- **Impact**: Minimal — rename + re-export. The type structure is correct; only its namespace location is over-specific.
- **Severity**: LOW — functionally correct, namespace imprecision only.

### All Other Types — No Relocation Needed

Systematic scan of remaining 65 files confirms all other types encode io_uring-specific concepts:

| Category | Types | Count | Verdict |
|----------|-------|-------|---------|
| Ring management | `Uring`, `Slot`, `Entry`, `Submission.*`, `Completion.*` | 20 | L2 ✓ — io_uring ring structures |
| Opcode namespaces | `Read`, `Write`, `Socket`, `File`, `Pipe`, `Xattr`, etc. | 25 | L2 ✓ — io_uring opcode constants |
| Flag types | `Setup.Options`, `Enter.Options`, `Cancel.Options`, etc. | 12 | L2 ✓ — io_uring flag constants |
| Support types | `Error`, `Wakeup`, `Target`, `Fixed`, `Message`, etc. | 8 | L2 ✓ — io_uring-specific abstractions |

No L1 candidates identified. io_uring is entirely Linux kernel-defined — there are no cross-platform vocabulary types to extract to primitives. No L3 candidates identified — all types are spec-encoding, not composed abstractions.

### Summary

| Type | Current Layer | Recommended | Action |
|------|--------------|-------------|--------|
| `Vector` | L2 io_uring | L2 POSIX (swift-iso-9945) | Define typed `iovec` struct in POSIX, io_uring uses it |
| `Timeout.Specification` | L2 io_uring | L2 POSIX (swift-iso-9945) | Define `Kernel.Time.Specification` in POSIX |
| `Priority` | L2 io_uring | L2 Linux Kernel IO Standard | Investigate shared `Kernel.IO.Priority` |
| All other types (85) | L2 io_uring | L2 io_uring (stays) | No action |

**Key finding**: The io_uring module is correctly placed at L2. Only 3 of 88 types have placement concerns, and all are POSIX/Linux general-purpose types that io_uring reuses rather than io_uring-specific definitions. The relocations are namespace precision improvements, not architectural violations.

---

## Legacy — Consolidated 2026-04-08

### From: swift-institute/Research/audit-primitives.md (2026-04-03)

**Pre-publication dependency-tree audit — P0/P1/P2 checks**

#### P2: Methods in Type Body [API-IMPL-008]

All in `Sources/Linux Kernel Primitives/`:

| File | Items in body |
|------|---------------|
| `Linux.Kernel.IO.Uring.Submission.Queue.Entry.Prepare.swift` | 12 |
| `Linux.Kernel.IO.Uring.Submission.Queue.Entry.swift` | 10 |
| `Linux.Kernel.IO.Uring.swift` | 7 |
| `Linux.Kernel.IO.Uring.Completion.Queue.Entry.swift` | 7 |

**Assessment**: Platform packages consistently define methods inside struct/enum bodies rather than using extensions. This appears to be a systematic pattern in the platform layer, possibly because these are thin syscall wrappers where the extension pattern adds overhead without benefit.

**Recommendation**: Consider as a batch cleanup across all platform packages, but lower priority since these are platform-specific code.

---

### From: swift-institute/Research/audits/implementation-naming-2026-03-20/swift-linux-primitives.md (2026-03-20)

**Implementation + naming audit**

HIGH=1, MEDIUM=3, LOW=20, INFO=34
Finding IDs: IMPL-010, LNX-001, LNX-002, LNX-003, LNX-004, LNX-005, LNX-006, LNX-007, LNX-008, LNX-009, LNX-010, LNX-011, LNX-012, LNX-013, LNX-014 (+28 more)

---

### From: Audits/file-audit/*.swift.audit.md (2026-04-12, 83 files)

**Per-file audit sweep of `Linux Kernel IO Uring Standard` target**

Rules checked per file: `API-NAME-001`, `API-NAME-002`, `API-NAME-003`, `API-ERR-001`, `API-ERR-002`, `API-ERR-003`, `API-IMPL-005`, `API-IMPL-006`, `API-IMPL-007`, `API-IMPL-008`, `IMPL-002`, `IMPL-064`, `IMPL-065`, `IMPL-067`, `IMPL-COMPILE`, plus doc-comment and unsafe-ops observations.

**Disposition**: Superseded on 2026-04-21 by the `## Code Surface — 2026-04-10` (resolved 10/11 with 1 DEFERRED), `## Implementation (Domain Modelling) — 2026-04-09`, `## V6 Ergonomics — 2026-04-12`, `## Spec Completeness — 2026-04-12`, `## Post-Closure Review — 2026-04-13` (12 RESOLVED), and `## Module Placement — 2026-04-12` sections above. Every substantive finding (compound method names → nested accessors, one-type-per-file extractions, Register spec corrections, `Space`/`Send.Zero`/`Rings.Descriptor`/`Files.Alloc`/`Buffers.Provided`/`Message.Kind` extractions, `Completion.Queue.Entry+Multishot` rename, `cValue` moved to extensions) is already tracked as RESOLVED in the superseding sections. Only one legacy observation remains — the static `Kernel.IO.Uring.close(_:)` method being a potential double-close footgun adjacent to deinit — and that is an implementation-hygiene concern, not a platform-rule violation, so it does not surface in the Platform section. Directory removed per [AUDIT-015].
