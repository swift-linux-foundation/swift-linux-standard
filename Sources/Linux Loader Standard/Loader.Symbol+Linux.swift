// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-linux project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android)

public import Loader_Primitives
internal import String_Primitives
#if canImport(Glibc)
internal import Glibc
#elseif canImport(Musl)
internal import Musl
#endif
internal import CLinuxKernelShim

// MARK: - dlsym Handle Conversion

extension Loader.Symbol.Scope {
    /// Converts scope to the `dlsym` handle pointer for Linux.
    ///
    /// `RTLD_DEFAULT` and `RTLD_NEXT` are GNU extensions gated by `_GNU_SOURCE`
    /// on glibc; `CLinuxKernelShim` exposes them via simple C functions so the
    /// L2 Swift code does not have to carry the feature-test macro.
    @unsafe
    fileprivate var dlsymHandle: UnsafeMutableRawPointer? {
        switch unsafe self {
        case .handle(let h):
            return unsafe h.rawValue
        case .default:
            return unsafe swift_RTLD_DEFAULT()
        case .next:
            return unsafe swift_RTLD_NEXT()
        }
    }
}

// MARK: - Symbol Lookup

extension Loader.Symbol {
    /// Looks up a symbol in a library or scope on Linux.
    ///
    /// Wraps `dlsym(3)`.
    ///
    /// - Parameters:
    ///   - name: The symbol name (C string).
    ///   - scope: Where to search — a loaded `Handle` or special scope.
    /// - Returns: Pointer to the symbol.
    /// - Throws: `Loader.Error.symbol` if not found.
    ///
    /// ## Pointer Lifetime
    ///
    /// - Returned `UnsafeRawPointer` is valid only while the owning library remains loaded.
    /// - Caller is responsible for correct casting and calling convention.
    @unsafe
    public static func lookup(
        name: UnsafePointer<CChar>,
        in scope: Scope
    ) throws(Loader.Error) -> UnsafeRawPointer {
        _ = unsafe dlerror()

        let sym = unsafe dlsym(scope.dlsymHandle, name)

        if let errorCStr = unsafe dlerror() {
            let u8Ptr = unsafe UnsafeRawPointer(errorCStr).assumingMemoryBound(to: UInt8.self)
            let view = unsafe String_Primitives.String.Borrowed(u8Ptr, count: String_Primitives.String.length(of: u8Ptr))
            throw .symbol(unsafe Loader.Message(copying: view))
        }

        guard let sym = unsafe sym else {
            throw .symbol(Loader.Message(ascii: "symbol resolved to NULL (no dlerror)"))
        }

        return UnsafeRawPointer(sym)
    }
}

#endif
