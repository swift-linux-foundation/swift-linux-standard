# io_uring SQE Pointer Elimination

<!--
---
version: 1.0.0
last_updated: 2026-04-12
status: DECISION
---
-->

## Context

The io_uring Prepare API exposes `UnsafeMutablePointer<Entry>` in the public API. `ring.nextEntry()` returns a raw pointer, wrapped in a `~Copyable` Prepare type. This conflicts with [PLAT-ARCH-005a] and requires 21+ view types to restore `@inlinable`.

`Lifetimes` and `LifetimeDependence` are enabled in this package. `~Escapable` is available now.

## Question

Can the SQE preparation API eliminate `UnsafeMutablePointer` from the public surface using `~Copyable ~Escapable` slot types with `nonmutating _modify` — zero pointers, zero closures, zero view-type proliferation?

## Analysis

### Architecture

Ring returns a `~Copyable ~Escapable` slot. Preparation methods are `mutating` on Entry, accessed through the slot's `nonmutating _modify` accessor. The pointer stays internal.

```swift
extension Kernel.IO.Uring {
    /// A slot in the submission queue ring buffer.
    ///
    /// ~Copyable: prevents aliasing — each slot used exactly once.
    /// ~Escapable: lifetime-bound to the ring — can't outlive the mmap.
    public struct Slot: ~Copyable, ~Escapable {
        @usableFromInline
        let pointer: UnsafeMutablePointer<Submission.Queue.Entry>

        @inlinable
        public var entry: Submission.Queue.Entry {
            _read { yield unsafe pointer.pointee }
            nonmutating _modify { yield &pointer.pointee }
        }
    }

    @inlinable
    public mutating func nextEntry() -> Slot? /* dependsOn(self) */ {
        guard let ptr = unsafe _nextEntryPointer() else { return nil }
        return unsafe Slot(pointer: ptr)
    }

    @usableFromInline
    mutating func _nextEntryPointer() -> UnsafeMutablePointer<Submission.Queue.Entry>? {
        // existing nextEntry() logic — stays internal
    }
}
```

Entry preparation:
```swift
extension Kernel.IO.Uring.Submission.Queue.Entry {
    @inlinable
    public mutating func read(
        target: borrowing Kernel.IO.Uring.Target,
        buffer: UnsafeMutableRawPointer,
        length: Kernel.IO.Uring.Length,
        offset: Kernel.IO.Uring.Offset,
        data: Kernel.IO.Uring.Operation.Data
    ) {
        self = .init()
        self.opcode = .read.standard
        target.apply(to: &self)
        self.addr = UInt64(UInt(bitPattern: buffer))
        self.len = length
        self.offset = offset
        self.data = data
    }
}
```

Call site:
```swift
if var slot = ring.nextEntry() {
    slot.entry.read(
        target: .descriptor(fd),
        buffer: buf,
        length: .init(4096),
        offset: .zero,
        data: id
    )
    ring.advance()
}

// Linked operations — natural
if var sqe1 = ring.nextEntry() {
    sqe1.entry.read(target: .descriptor(fd), ...)
    sqe1.entry.flags.insert(.link)
    ring.advance()
}
if var sqe2 = ring.nextEntry() {
    sqe2.entry.timeout(link: timespec, clock: .monotonic, data: linkData)
    ring.advance()
}
let n = ring.flush()
```

Target.apply becomes `inout Entry`:
```swift
extension Kernel.IO.Uring.Target {
    @inlinable
    func apply(to entry: inout Kernel.IO.Uring.Submission.Queue.Entry) {
        switch self {
        case .descriptor(let fd): entry._fd = fd._rawValue
        case .registered(let index):
            entry._fd = Int32(bitPattern: index)
            entry.flags.insert(.fixedFile)
        case .allocate:
            entry._fd = Int32(bitPattern: UInt32.max)
            entry.flags.insert(.fixedFile)
        case .none: entry._fd = -1
        }
    }
}
```

### Why @inlinable works naturally

Entry's `mutating func read(...)` accesses `self.opcode`, `self.addr`, `self.len`, etc. — all public typed accessors. No `cValue` reference in the body. Overloaded union fields use `@usableFromInline internal` accessors (`_fd`, `_rawLength`, `_rawFlags`, etc.) — ~11 computed properties, not 21 types.

The `@inlinable` chain: caller → `@inlinable` `slot.entry` (`nonmutating _modify`) → `@inlinable` `entry.read(...)` → public/`@usableFromInline` Entry accessors.

### What gets eliminated

| Thing | Current | After |
|-------|---------|-------|
| Prepare type | 1 type + 65 methods | **Eliminated** — methods on Entry |
| View types | 21 planned | **Eliminated** — no indirection needed |
| Pointer in public API | `UnsafeMutablePointer<Entry>` | **Zero** — Slot wraps pointer internally |
| `prepare` accessor | On UnsafeMutablePointer | **Eliminated** — `slot.entry` instead |
| New types needed | 21+ | **1** (Slot) |
| @usableFromInline accessors on Entry | 0 → 21+ views | **~11** computed properties |

### What stays

- `@usableFromInline` raw accessors on Entry for overloaded union fields: `_fd`, `_rawLength`, `_rawOffset`, `_rawFlags`, `_bufferIndex`, `_bufferGroup`, `_spliceSourceFd`, `_pollEvents`, `_commandOpcode`, `_fileIndex`, `_addr3`
- `internal var cValue: io_uring_sqe` — unchanged, accessed only by the `@usableFromInline` accessors
- The mmap'd ring buffer mechanics — unchanged

## Outcome

**Status**: DECISION

Use `~Copyable ~Escapable` Slot type. Preparation methods become `mutating` on Entry directly. The Prepare type and all 21 planned view types are eliminated.

### Implementation path

1. Add ~11 `@usableFromInline` raw field accessors to Entry (for overloaded union fields)
2. Move all 65 Prepare methods to `mutating` methods on Entry (with `@inlinable`)
3. Create `Kernel.IO.Uring.Slot` (`~Copyable ~Escapable`, 1 file)
4. Change `ring.nextEntry()` to return `Slot?` instead of `UnsafeMutablePointer<Entry>?`
5. Change `Target.apply(to:)` from `UnsafeMutablePointer<Entry>` to `inout Entry`
6. Delete Prepare type and all view-type files
7. Restore `@usableFromInline` on `Clock.timeoutBits`, `Poll.Trigger.pollBits`, `File.Xattr.Disposition.rawBits`

## References

- [PLAT-ARCH-005a] No platform C types in public API
- [IMPL-071] nonmutating _modify for interior mutability
- [IMPL-064] ~Copyable as default posture
- [IMPL-065] ~Escapable for scoped access
- [IMPL-COMPILE] Compiler as primary correctness mechanism
- Swift Lifetimes / LifetimeDependence (experimental, enabled in Package.swift)
