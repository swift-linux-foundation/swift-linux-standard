#if os(Linux)
    import Testing

    import Memory
    @testable import Linux_Kernel_IO_Uring_Standard

    @Suite
    struct `Ring Byte Offset Tests` {

        @Test
        func `a kernel ring offset converts to the same byte count`() {
            #expect(_ringByteOffset(Memory.Address.Offset(UInt32(64))) == 64)
        }

        @Test
        func `the zero ring offset converts to zero bytes`() {
            #expect(_ringByteOffset(Memory.Address.Offset(UInt32(0))) == 0)
        }

        @Test
        func `the largest kernel ring offset converts without truncation`() {
            #expect(_ringByteOffset(Memory.Address.Offset(UInt32.max)) == Int(UInt32.max))
        }
    }
#endif
