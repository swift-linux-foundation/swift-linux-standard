// Linux.Identity.UUID.swift
// Native UUID parsing using libuuid

#if os(Linux)
import CLinuxKernelShim
public import Linux_Primitives_Core

extension Linux_Primitives_Core.Linux {
    /// Identity-related types for Linux.
    public enum Identity {}
}

extension Linux.Identity {
    /// Native UUID parsing using libuuid.
    public enum UUID {}
}

extension Linux.Identity.UUID {
    /// 16-byte tuple type matching RFC 4122 storage.
    public typealias Bytes = (
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
    )

    /// Parses RFC 4122 hyphenated format to 16 bytes.
    ///
    /// Uses libuuid's native `uuid_parse` for optimal performance.
    /// Only accepts 36-character hyphenated format.
    ///
    /// - Parameter string: UUID string in format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
    /// - Returns: 16 bytes in big-endian order, or nil if parsing fails.
    public static func parse(_ string: String) -> Bytes? {
        var bytes: Bytes = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        let result = string.withCString { cString in
            withUnsafeMutableBytes(of: &bytes) { buffer in
                swift_uuid_parse(cString, buffer.baseAddress!.assumingMemoryBound(to: UInt8.self))
            }
        }
        return result == 0 ? bytes : nil
    }

    /// The fixed length of an unparsed UUID string (excluding NUL terminator).
    public static let unparseLength: Int = 36

    // MARK: - Borrow-First APIs

    /// Canonical primitive: scoped access to unparsed UUID bytes.
    ///
    /// This is the most primitive API. It provides zero-copy access to the
    /// formatted UUID bytes. The closure receives a `Span` of exactly 36
    /// characters (excluding NUL terminator).
    ///
    /// - Parameters:
    ///   - bytes: 16 bytes in big-endian order.
    ///   - uppercase: Whether to use uppercase hex digits (default: false).
    ///   - body: A closure that processes the formatted bytes. Non-throwing.
    /// - Returns: The result of the closure.
    public static func withUnparsedBytes<R: ~Copyable>(
        _ bytes: Bytes,
        uppercase: Bool = false,
        _ body: (Span<CChar>) -> R
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

    /// Convenience: scoped access to unparsed UUID as String.
    ///
    /// This API provides scoped access to the formatted UUID without
    /// allocating an owned String.
    ///
    /// - Parameters:
    ///   - bytes: 16 bytes in big-endian order.
    ///   - uppercase: Whether to use uppercase hex digits (default: false).
    ///   - body: A closure that processes the formatted string. Non-throwing.
    /// - Returns: The result of the closure.
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

    /// Owned convenience: formats 16 bytes to RFC 4122 hyphenated string.
    ///
    /// This is the simplest API but involves allocation. For callers that
    /// need to use the result temporarily (e.g., logging, comparison),
    /// prefer `withUnparsedBytes` or `withUnparsed` to avoid allocation.
    ///
    /// Uses libuuid's native `uuid_unparse` for optimal performance.
    ///
    /// - Parameters:
    ///   - bytes: 16 bytes in big-endian order.
    ///   - uppercase: Whether to use uppercase hex digits (default: false).
    /// - Returns: Formatted UUID string.
    public static func unparse(_ bytes: Bytes, uppercase: Bool = false) -> String {
        withUnparsed(bytes, uppercase: uppercase) { str in
            str
        }
    }
}
#endif
