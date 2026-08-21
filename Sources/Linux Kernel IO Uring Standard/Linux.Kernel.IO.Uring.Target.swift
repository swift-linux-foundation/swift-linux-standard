#if os(Linux)

    @_spi(Syscall) public import ISO_9945_Core
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension ISO_9945.Kernel.IO.Uring {

        public enum Target: ~Copyable, ~Escapable {

            case descriptor(Int32)

            case registered(UInt32)

            case allocate

            case none
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Target {

        @_lifetime(borrow descriptor)
        public init(descriptor: borrowing ISO_9945.Kernel.Descriptor) {
            self = .descriptor(descriptor._rawValue)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Target {

        @usableFromInline
        func apply(
            to sqe: inout ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry
        ) {
            switch self {
            case .descriptor(let fd):
                sqe._fd = fd

            case .registered(let index):
                sqe._fd = Int32(bitPattern: index)
                sqe.flags.insert(.fixedFile)

            case .allocate:
                sqe._fd = Int32(bitPattern: UInt32.max)
                sqe.flags.insert(.fixedFile)

            case .none:
                sqe._fd = -1
            }
        }
    }

#endif
