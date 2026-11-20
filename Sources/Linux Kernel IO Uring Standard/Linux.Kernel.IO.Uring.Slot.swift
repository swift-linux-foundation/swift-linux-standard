#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {

        @safe public struct Slot: ~Copyable, ~Escapable {
            @usableFromInline
            let pointer: UnsafeMutablePointer<Submission.Queue.Entry>

            @_lifetime(borrow pointer)
            @usableFromInline @unsafe
            init(_ pointer: UnsafeMutablePointer<Submission.Queue.Entry>) {
                unsafe self.pointer = unsafe pointer
            }
        }
    }

    extension Linux.Kernel.IO.Uring.Slot {
        @inlinable
        public var entry: Linux.Kernel.IO.Uring.Submission.Queue.Entry {
            _read { yield unsafe pointer.pointee }
            nonmutating _modify { yield unsafe &pointer.pointee }
        }
    }

#endif
