#if os(Linux)
    import Linux_Kernel_Shims
    public import Linux_Standard_Core

    extension Linux_Standard_Core.Linux {

        public enum Identity {}
    }

    extension Linux.Identity {

        public enum UUID {}
    }

    extension Linux.Identity.UUID {

        public typealias Bytes = (
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
        )

        public static func parse(_ string: String) -> Bytes? {
            var bytes: Bytes = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            let result = string.withCString { cString in
                withUnsafeMutableBytes(of: &bytes) { buffer in
                    swift_uuid_parse(
                        cString,
                        buffer.baseAddress!.assumingMemoryBound(to: UInt8.self)
                    )
                }
            }
            return result == 0 ? bytes : nil
        }

        public static let unparseLength: Int = 36

        public static func withUnparsedBytes<R: ~Copyable>(
            _ bytes: Bytes,
            uppercase: Bool = false,
            _ body: (Swift.Span<CChar>) -> R
        ) -> R {
            var output = (
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0),
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0),
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0),
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0),
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0)
            )
            withUnsafeBytes(of: bytes) { input in
                withUnsafeMutableBytes(of: &output) { outputBuffer in
                    let outputPtr = outputBuffer.baseAddress!.assumingMemoryBound(to: CChar.self)
                    if uppercase {
                        swift_uuid_unparse_upper(
                            input.baseAddress!.assumingMemoryBound(to: UInt8.self),
                            outputPtr
                        )
                    } else {
                        swift_uuid_unparse_lower(
                            input.baseAddress!.assumingMemoryBound(to: UInt8.self),
                            outputPtr
                        )
                    }
                }
            }
            return withUnsafeBytes(of: output) { buffer in
                let ptr = buffer.baseAddress!.assumingMemoryBound(to: CChar.self)
                let span = Span(_unsafeStart: ptr, count: 36)
                return body(span)
            }
        }

        public static func withUnparsed<R: ~Copyable>(
            _ bytes: Bytes,
            uppercase: Bool = false,
            _ body: (String) -> R
        ) -> R {
            var output = (
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0),
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0),
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0),
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0),
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0)
            )
            withUnsafeBytes(of: bytes) { input in
                withUnsafeMutableBytes(of: &output) { outputBuffer in
                    let outputPtr = outputBuffer.baseAddress!.assumingMemoryBound(to: CChar.self)
                    if uppercase {
                        swift_uuid_unparse_upper(
                            input.baseAddress!.assumingMemoryBound(to: UInt8.self),
                            outputPtr
                        )
                    } else {
                        swift_uuid_unparse_lower(
                            input.baseAddress!.assumingMemoryBound(to: UInt8.self),
                            outputPtr
                        )
                    }
                }
            }
            return withUnsafeBytes(of: output) { buffer in
                let ptr = buffer.baseAddress!.assumingMemoryBound(to: CChar.self)
                let str = String(cString: ptr)
                return body(str)
            }
        }

        public static func unparse(_ bytes: Bytes, uppercase: Bool = false) -> String {
            withUnparsed(bytes, uppercase: uppercase) { str in
                str
            }
        }
    }
#endif
