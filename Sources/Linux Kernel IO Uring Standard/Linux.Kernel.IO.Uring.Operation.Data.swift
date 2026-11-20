#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Operation {

        public typealias Data = Tagged<Linux.Kernel.IO.Uring.Operation, UInt64>
    }

    extension Linux.Kernel.IO.Uring.Operation.Data {

        @unsafe
        public init(_ pointer: UnsafeRawPointer) {
            self.init(_unchecked: UInt64(UInt(bitPattern: pointer)))
        }

        @unsafe
        public init<T>(pointer: UnsafePointer<T>) {
            self.init(_unchecked: UInt64(UInt(bitPattern: pointer)))
        }

        @unsafe
        public init<T>(pointer: UnsafeMutablePointer<T>) {
            self.init(_unchecked: UInt64(UInt(bitPattern: pointer)))
        }
    }

    extension Linux.Kernel.IO.Uring.Operation.Data {

        public static let zero: Self = .init(_unchecked: 0)
    }

#endif
