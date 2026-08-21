#if os(Linux)

    public import ISO_9945_Core
    public import Error_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension ISO_9945.Kernel.IO.Uring.Completion.Queue {

        public struct Entry: Sendable {

            internal let cValue: io_uring_cqe

            internal init(_ cValue: io_uring_cqe) {
                self.cValue = cValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry {

        public var data: ISO_9945.Kernel.IO.Uring.Operation.Data {
            ISO_9945.Kernel.IO.Uring.Operation.Data(_unchecked: cValue.user_data)
        }

        @usableFromInline
        internal var res: Int32 {
            cValue.res
        }

        public var flags: Options {
            Options(rawValue: cValue.flags)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry {

        public var isSuccess: Bool {
            res >= 0
        }

        public var isError: Bool {
            res < 0
        }

        public var isCancelled: Bool {
            res == -Int32(ECANCELED)
        }

        public var errorNumber: Error_Primitives.Error.Number? {
            isError ? Error_Primitives.Error.Number(_unchecked: -res) : nil
        }
    }

#endif
