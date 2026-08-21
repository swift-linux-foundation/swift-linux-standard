#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    public import Binary_Primitives

    extension ISO_9945.Kernel.IO.Uring {

        public typealias Length = Magnitude<Space>.Value<UInt32>
    }

    extension ISO_9945.Kernel.IO.Uring.Length {

        public static let zero: Self = .init(UInt32(0))

        public init(_ count: Int) {
            self.init(UInt32(clamping: count))
        }

        @unsafe
        public init(_ buffer: UnsafeRawBufferPointer) {
            self.init(UInt32(clamping: unsafe buffer.count))
        }

        @unsafe
        public init(_ buffer: UnsafeMutableRawBufferPointer) {
            self.init(UInt32(clamping: unsafe buffer.count))
        }

        public init(_ span: Swift.Span<UInt8>) {
            self.init(UInt32(clamping: span.count))
        }

        public init(_ span: borrowing MutableSpan<UInt8>) {
            self.init(UInt32(clamping: span.count))
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Length {

        public init(_ size: ISO_9945.Kernel.File.Size) {
            if size.underlying > Int64(UInt32.max) {
                self.init(UInt32.max)
            } else if size.underlying < 0 {
                self.init(UInt32(0))
            } else {
                self.init(UInt32(size.underlying))
            }
        }
    }

#endif
