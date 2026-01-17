// Linux.Identity.UUID.swift
// Native UUID parsing using libuuid

#if canImport(Glibc) || canImport(Musl)
import CLinuxKernelShim
public import Linux_Primitives

extension Linux_Primitives.Linux {
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

    /// Formats 16 bytes to RFC 4122 hyphenated string.
    ///
    /// Uses libuuid's native `uuid_unparse` for optimal performance.
    ///
    /// - Parameters:
    ///   - bytes: 16 bytes in big-endian order.
    ///   - uppercase: Whether to use uppercase hex digits (default: false).
    /// - Returns: Formatted UUID string.
    public static func unparse(_ bytes: Bytes, uppercase: Bool = false) -> String {
        var output = [CChar](repeating: 0, count: 37)
        withUnsafeBytes(of: bytes) { input in
            if uppercase {
                swift_uuid_unparse_upper(
                    input.baseAddress!.assumingMemoryBound(to: UInt8.self),
                    &output
                )
            } else {
                swift_uuid_unparse_lower(
                    input.baseAddress!.assumingMemoryBound(to: UInt8.self),
                    &output
                )
            }
        }
        return String(cString: output)
    }
}
#endif
