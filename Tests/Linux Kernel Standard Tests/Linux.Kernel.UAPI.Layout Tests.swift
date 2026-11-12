#if os(Linux)
    import Testing
    import Linux_Kernel_Reference_Shims

    enum `Linux Kernel UAPI Layout` {
        struct Entry: Equatable, CustomStringConvertible {
            let name: String
            let value: UInt64

            var description: String { "\(name) = \(value)" }
        }

        static func entries(
            _ count: Int,
            _ table: UnsafePointer<swift_linux_uapi_entry>?
        ) -> [Entry] {
            guard let table = unsafe table else { return [] }
            return (0..<count).map { index in
                unsafe Entry(name: String(cString: table[index].name), value: table[index].value)
            }
        }

        static let declared = unsafe entries(
            swift_linux_uapi_declared_count(),
            swift_linux_uapi_declared()
        )

        static let kernel = unsafe entries(
            swift_linux_uapi_kernel_count(),
            swift_linux_uapi_kernel()
        )

        @Suite struct Unit {}
    }

    extension `Linux Kernel UAPI Layout`.Unit {
        @Test
        func `every declared size offset and constant is listed`() {
            #expect(`Linux Kernel UAPI Layout`.declared.count == 126)
        }

        @Test
        func `declared sizes match the kernel ABI`() {
            let sizes = Dictionary(
                uniqueKeysWithValues: `Linux Kernel UAPI Layout`.declared.map { ($0.name, $0.value) }
            )
            #expect(sizes["sizeof(struct io_uring_sqe)"] == 64)
            #expect(sizes["sizeof(struct io_uring_cqe)"] == 16)
            #expect(sizes["sizeof(struct io_sqring_offsets)"] == 40)
            #expect(sizes["sizeof(struct io_cqring_offsets)"] == 40)
            #expect(sizes["sizeof(struct io_uring_params)"] == 120)
            #expect(sizes["sizeof(struct open_how)"] == 24)
            #expect(sizes["sizeof(struct statx_timestamp)"] == 16)
            #expect(sizes["sizeof(struct statx)"] == 256)
            #expect(sizes["offsetof(struct statx, stx_mnt_id)"] == 0x90)
            #expect(sizes["offsetof(struct io_uring_sqe, addr3)"] == 48)
        }

        @Test(.enabled(if: !`Linux Kernel UAPI Layout`.kernel.isEmpty, "needs the kernel's UAPI headers"))
        func `declared layouts and constants equal the kernel UAPI headers`() {
            #expect(`Linux Kernel UAPI Layout`.declared == `Linux Kernel UAPI Layout`.kernel)
        }
    }
#endif
