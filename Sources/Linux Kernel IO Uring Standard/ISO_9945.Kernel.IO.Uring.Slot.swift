#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        // SAFETY: Category C. The slot borrows the queue-owned entry pointer for its entire
        // lifetime and cannot escape that borrow.
        @safe public struct Slot: ~Copyable, ~Escapable {
            @usableFromInline
            let pointer: UnsafeMutablePointer<Submission.Queue.Entry>

            @lifetime(borrow pointer)
            @usableFromInline @unsafe
            init(_ pointer: UnsafeMutablePointer<Submission.Queue.Entry>) {
                self.pointer = unsafe pointer
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Slot {
        @inlinable
        public var entry: ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {
            _read { yield unsafe pointer.pointee }
            nonmutating _modify { yield unsafe &pointer.pointee }
        }
    }

#endif
