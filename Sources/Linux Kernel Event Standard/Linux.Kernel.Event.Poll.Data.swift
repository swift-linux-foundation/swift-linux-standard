#if os(Linux)

    public import ISO_9945_Core
    public import Linux_Standard_Core
    public import Error_Primitives

    extension Linux.Kernel.Event.Poll {

        public typealias Data = Tagged<Linux.Kernel.Event.Poll, UInt64>
    }

    extension Linux.Kernel.Event.Poll.Data {

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

    extension Linux.Kernel.Event.Poll.Data {

        public static let zero: Self = .init(_unchecked: 0)
    }

#endif
