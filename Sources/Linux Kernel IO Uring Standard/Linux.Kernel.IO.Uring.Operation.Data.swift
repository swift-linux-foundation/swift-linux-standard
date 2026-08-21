#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Operation {

        public typealias Data = Tagged<ISO_9945.Kernel.IO.Uring.Operation, UInt64>
    }

    extension ISO_9945.Kernel.IO.Uring.Operation.Data {

        @unsafe
        public init(_ pointer: UnsafeRawPointer) {
            self.init(_unchecked: UInt64(UInt(bitPattern: unsafe pointer)))
        }

        @unsafe
        public init<T>(pointer: UnsafePointer<T>) {
            self.init(_unchecked: UInt64(UInt(bitPattern: unsafe pointer)))
        }

        @unsafe
        public init<T>(pointer: UnsafeMutablePointer<T>) {
            self.init(_unchecked: UInt64(UInt(bitPattern: unsafe pointer)))
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Operation.Data {

        public static let zero: Self = .init(_unchecked: 0)
    }

#endif
