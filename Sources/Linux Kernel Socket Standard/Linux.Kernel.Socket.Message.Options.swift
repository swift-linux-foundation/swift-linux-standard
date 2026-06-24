#if os(Linux)

public import ISO_9945_Core
public import ISO_9945_Kernel_Socket
#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Linux-Specific Socket Message Flags
//
// POSIX flags (MSG_OOB, MSG_PEEK, MSG_WAITALL, MSG_EOR, MSG_DONTROUTE,
// MSG_TRUNC, MSG_CTRUNC, MSG_DONTWAIT) are in ISO 9945 Kernel Socket.
// Only Linux-specific flags remain here.

extension ISO_9945.Kernel.Socket.Message.Options {
    /// Hint that more data will follow (MSG_MORE).
    public static let more = Self(rawValue: Int32(MSG_MORE))

    /// Confirm path validity (MSG_CONFIRM).
    public static let confirm = Self(rawValue: Int32(MSG_CONFIRM))
}

#endif
