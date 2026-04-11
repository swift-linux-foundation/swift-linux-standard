#if os(Linux)

public import Kernel_Primitives_Core
public import Kernel_Process_Primitives
public import ISO_9945_Kernel_Signal

#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Kernel.Signal {
    /// Signal information delivered by the kernel.
    ///
    /// Wraps the platform `siginfo_t` struct. An
    /// `UnsafeMutablePointer<Information>` may be passed directly to
    /// kernel interfaces that expect `siginfo_t *`.
    public struct Information: @unchecked Sendable {
        internal var cValue: siginfo_t

        /// Creates a zeroed signal information buffer.
        public init() {
            self.cValue = siginfo_t()
        }
    }
}

// MARK: - Accessors

extension Kernel.Signal.Information {
    /// Signal number.
    public var signal: Int32 {
        get { cValue.si_signo }
    }

    /// Error number associated with this signal.
    public var error: Int32 {
        get { cValue.si_errno }
    }

    /// Signal code (indicates the cause of the signal).
    public var code: Code {
        get { Code(rawValue: cValue.si_code) }
    }

    /// Process ID of the sending process (or child, for SIGCHLD).
    public var pid: Kernel.Process.ID {
        get { Kernel.Process.ID(rawValue: cValue._sifields._kill.si_pid) }
    }

    /// Real user ID of the sending process.
    public var uid: Kernel.User.ID {
        get { Kernel.User.ID(__unchecked: (), cValue._sifields._kill.si_uid) }
    }

    /// Exit status or signal number (for SIGCHLD).
    public var status: Int32 {
        get { cValue._sifields._sigchld.si_status }
    }
}

#endif
