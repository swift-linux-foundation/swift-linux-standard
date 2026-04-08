# Audit: swift-linux-primitives

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
