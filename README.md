# swift-linux-standard

Use this package when you need what only Linux offers beyond POSIX: eventfd, epoll, io_uring, signalfd, timerfd and pidfd, reflink clones and `copy_file_range`, `renameat2`, `statx`, `openat2`, extended attributes, getrandom, thread affinity, and reading CPU and memory topology from sysfs. Start from `Linux.Kernel` for Linux-only facilities such as `Linux.Kernel.Event.Poll` and `Linux.Kernel.File.Clone`, and from the Linux additions to `ISO_9945.Kernel`, such as `ISO_9945.Kernel.IO.Uring`. Each area is its own product. For the POSIX interfaces themselves, use swift-iso-9945. For higher-level epoll and io_uring, use swift-linux. For code that must also run on macOS and Windows, use swift-kernel.

## Laws

- Everything is compiled only when building for Linux, apart from a few pieces that also build for Android or the BSDs.
- The eventfd, epoll, signalfd and timerfd descriptors this package creates are close-on-exec unless you pass other flags. A timerfd uses the monotonic clock unless you pass another.
- `Linux.Kernel.Event.Descriptor.signal()` never fails: a counter that is already full, or a descriptor that is already closed, is ignored. Reading or writing a non-blocking event descriptor that is not ready fails as would-block.
- Read interest on epoll also asks for peer hang-up. Polling into an empty event array returns 0 at once without waiting. A wait interrupted by a signal fails as interrupted rather than with an error code.
- `Linux.Kernel.File.Clone.Capability.probe(at:)` reports reflink support only for Btrfs and XFS. `Linux.Kernel.File.Clone.Ficlone.attempt(source:destination:)` returns false, rather than throwing, when the filesystem cannot clone or the files are on different devices. `Linux.Kernel.File.Clone.CopyRange.copy(source:destination:length:)` stops without an error if the source ends before `length` bytes.
- In `Linux.Kernel.Copy.Error`, `EINVAL`, `ENOTSUP`, `EOPNOTSUPP` and `ENOSYS` all mean unsupported. `renameat2` likewise reports `EINVAL` and `ENOSYS` as not supported.
- Every io_uring prepare method clears the whole submission entry before setting its fields. An `ISO_9945.Kernel.IO.Uring.Offset` made from a negative file offset means the current file position. An `ISO_9945.Kernel.IO.Uring.Length` clamps its count to the 32-bit range.
- `ISO_9945.Kernel.IO.Uring.next` names the same submission slot until `ISO_9945.Kernel.IO.Uring.advance()` is called, so preparing it twice keeps only the second entry. Advanced entries reach the kernel only after `ISO_9945.Kernel.IO.Uring.flush()`. `ISO_9945.Kernel.IO.Uring.drain(limit:_:)` releases each completion it visits back to the kernel. An `ISO_9945.Kernel.IO.Uring.enter(toSubmit:minComplete:flags:)` interrupted by a signal fails as interrupted rather than with an error code.
- `ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry.Bytes.transferred` is nil when the operation failed. `ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry.Buffer.index` is nil unless the kernel picked a provided buffer.
- `ISO_9945.Kernel.IO.Uring.Params.Submission.Thread.idle` reaches the kernel in whole milliseconds, rounded down.
- `Linux.Kernel.Random.getrandom(_:)` waits until the kernel's entropy pool is ready, may fill fewer bytes than asked, and returns how many it filled. An empty buffer returns 0.
- `Linux.Kernel.Thread.Affinity.setMask(tid:cores:)` with its default thread ID of 0 applies to the calling thread.
- `CPU.Core.count` counts distinct physical cores among the online processors and reports 1 when sysfs cannot be read. `CPU.NUMA.state` is uniform when the system has a single node. `Memory.Physical.capacity` is 0 when `/proc/meminfo` cannot be read.
- Linking the `Linux Memory Standard` product replaces `malloc` and `free` for the whole process. `Linux.Memory.Allocation.Statistics` counts per thread, starts counting at once, counts only `malloc` and `free`, and adds up the sizes requested.
