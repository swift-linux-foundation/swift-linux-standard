// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux-primitives open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-linux-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

public import Kernel_Primitives_Core
public import Kernel_Descriptor_Primitives
public import Kernel_Error_Primitives
public import Kernel_File_Primitives
public import Kernel_Memory_Primitives
public import Kernel_Random_Primitives
public import Kernel_Path_Primitives
public import Kernel_Socket_Primitives

#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Linux Socket Message Flags

extension Kernel.Socket.Message.Options {
    /// Do not block (MSG_DONTWAIT).
    public static let dontWait = Options(rawValue: Int32(MSG_DONTWAIT))

    /// Do not generate SIGPIPE (MSG_NOSIGNAL).
    public static let noSignal = Options(rawValue: Int32(MSG_NOSIGNAL))

    /// Send or receive out-of-band data (MSG_OOB).
    public static let outOfBand = Options(rawValue: Int32(MSG_OOB))

    /// Peek at incoming data without consuming it (MSG_PEEK).
    public static let peek = Options(rawValue: Int32(MSG_PEEK))

    /// Wait for the full request or an error (MSG_WAITALL).
    public static let waitAll = Options(rawValue: Int32(MSG_WAITALL))

    /// Terminates a record (MSG_EOR).
    public static let endOfRecord = Options(rawValue: Int32(MSG_EOR))

    /// Hint that more data will follow (MSG_MORE).
    public static let more = Options(rawValue: Int32(MSG_MORE))

    /// Do not use gateway routing (MSG_DONTROUTE).
    public static let dontRoute = Options(rawValue: Int32(MSG_DONTROUTE))

    /// Normal data was truncated (MSG_TRUNC).
    public static let truncate = Options(rawValue: Int32(MSG_TRUNC))

    /// Control data was truncated (MSG_CTRUNC).
    public static let controlTruncate = Options(rawValue: Int32(MSG_CTRUNC))

    /// Confirm path validity (MSG_CONFIRM).
    public static let confirm = Options(rawValue: Int32(MSG_CONFIRM))
}

#endif
