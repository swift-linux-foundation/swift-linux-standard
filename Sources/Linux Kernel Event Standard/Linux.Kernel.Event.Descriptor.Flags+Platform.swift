//
//  Linux.Kernel.Event.Descriptor.Create.Flags.swift
//  swift-linux-primitives
//
//  Platform flag constants for eventfd creation.
//

#if os(Linux)

public import Kernel_Event_Primitives
public import Error_Primitives

#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

#if canImport(CLinuxKernelShim)
    internal import CLinuxKernelShim
#endif

extension Kernel.Event.Descriptor.Flags {
    /// Close-on-exec: prevents the fd from leaking to child processes.
    ///
    /// - Linux: `EFD_CLOEXEC`
    public static let cloexec = Self(rawValue: Int32(EFD_CLOEXEC))

    /// Non-blocking: read/write return EAGAIN instead of blocking.
    ///
    /// - Linux: `EFD_NONBLOCK`
    public static let nonblock = Self(rawValue: Int32(EFD_NONBLOCK))

    /// Semaphore mode: read returns 1 and decrements by 1 instead
    /// of returning the full counter and resetting to zero.
    ///
    /// - Linux: `EFD_SEMAPHORE`
    public static let semaphore = Self(rawValue: Int32(EFD_SEMAPHORE))
}

#endif
