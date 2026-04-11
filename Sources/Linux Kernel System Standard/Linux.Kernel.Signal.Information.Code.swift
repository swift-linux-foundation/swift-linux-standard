#if os(Linux)

public import Kernel_Primitives_Core
public import ISO_9945_Kernel_Signal

#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Kernel.Signal.Information {
    /// Signal code indicating the cause of a signal.
    ///
    /// For SIGCHLD, the CLD_* values describe child process state changes.
    public struct Code: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - SIGCHLD Codes

extension Kernel.Signal.Information.Code {
    /// Child has exited normally.
    public static let exited = Self(rawValue: Int32(CLD_EXITED))

    /// Child was killed by a signal.
    public static let killed = Self(rawValue: Int32(CLD_KILLED))

    /// Child terminated abnormally (core dump).
    public static let dumped = Self(rawValue: Int32(CLD_DUMPED))

    /// Traced child has trapped.
    public static let trapped = Self(rawValue: Int32(CLD_TRAPPED))

    /// Child has stopped.
    public static let stopped = Self(rawValue: Int32(CLD_STOPPED))

    /// Stopped child has continued.
    public static let continued = Self(rawValue: Int32(CLD_CONTINUED))
}

#endif
