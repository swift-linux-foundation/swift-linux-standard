#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        @safe public struct Slot: ~Copyable, ~Escapable {
            @usableFromInline
            let pointer: UnsafeMutablePointer<Submission.Queue.Entry>

            @lifetime(borrow pointer)
            @usableFromInline @unsafe
            init(_ pointer: UnsafeMutablePointer<Submission.Queue.Entry>) {
                self.pointer = unsafe pointer
            }

            @inlinable
            public var entry: Submission.Queue.Entry {
                _read { yield unsafe pointer.pointee }
                nonmutating _modify { yield unsafe &pointer.pointee }
            }
        }
    }

#endif
