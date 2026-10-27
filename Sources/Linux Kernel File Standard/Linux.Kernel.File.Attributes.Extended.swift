#if os(Linux)

    @_spi(Syscall) public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    public import Path
    import Error

    #if canImport(Glibc)
        internal import Glibc
        internal import Linux_Kernel_Shims
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension ISO_9945.Kernel.File.Attributes {

        public enum Extended {}
    }

    extension ISO_9945.Kernel.File.Attributes.Extended {

        public struct Error: Swift::Error, Sendable {
            public let code: Error::Error.Code

            public init(code: Error::Error.Code) {
                self.code = code
            }
        }
    }

    extension ISO_9945.Kernel.File.Attributes.Extended.Error {

        public static let notFound = Error(code: .posix(ENODATA))

        public static let noSpace = Error(code: .posix(ENOSPC))

        public static let permissionDenied = Error(code: .posix(EACCES))

        @usableFromInline
        internal static func current() -> Self {
            Self(code: .posix(errno))
        }
    }

    extension ISO_9945.Kernel.File.Attributes.Extended {

        @unsafe
        private static func withCName<R, E: Swift::Error>(
            _ name: Swift::String,
            _ body: (UnsafePointer<CChar>) throws(E) -> R
        ) throws(E) -> R {
            var utf8 = Array(name.utf8)
            utf8.append(0)
            return try utf8.withUnsafeBufferPointer { buffer throws(E) in
                guard let base = buffer.baseAddress else {
                    preconditionFailure("A null-terminated array has a base address")
                }
                return try unsafe body(
                    UnsafeRawPointer(base).assumingMemoryBound(to: CChar.self)
                )
            }
        }

        @unsafe
        private static func withCPath<R, E: Swift::Error>(
            _ path: borrowing Path.Borrowed,
            _ body: (UnsafePointer<CChar>) throws(E) -> R
        ) throws(E) -> R {
            try unsafe path.withUnsafePointer { pointer throws(E) in
                try unsafe body(UnsafeRawPointer(pointer).assumingMemoryBound(to: CChar.self))
            }
        }

        @unsafe
        private static func probed<Element: BitwiseCopyable>(
            _ read: (UnsafeMutablePointer<Element>?, Int) -> Int
        ) throws(ISO_9945.Kernel.File.Attributes.Extended.Error) -> [Element] {
            while true {
                let size = read(nil, 0)
                guard size >= 0 else { throw .current() }
                if size == 0 { return [] }

                var buffer = [Element](unsafeUninitializedCapacity: size) { _, count in count = size }
                let result = unsafe buffer.withUnsafeMutableBufferPointer { read($0.baseAddress, size) }
                if result >= 0 {
                    return Array(buffer.prefix(result))
                }
                guard errno == ERANGE else { throw .current() }
            }
        }

        private static func names(_ buffer: [CChar]) -> [Swift::String] {
            buffer.split(separator: 0).compactMap { name in
                Swift::String(validating: name.map { UInt8(bitPattern: $0) }, as: UTF8.self)
            }
        }
    }

    extension ISO_9945.Kernel.File.Attributes.Extended {

        public static func list(
            path: borrowing Path.Borrowed,
            followSymlinks: Bool = true
        ) throws(ISO_9945.Kernel.File.Attributes.Extended.Error) -> [Swift::String] {
            let buffer = try unsafe withCPath(path) { cPath throws(ISO_9945.Kernel.File.Attributes.Extended.Error) in
                try unsafe probed { (buffer: UnsafeMutablePointer<CChar>?, size) in
                    followSymlinks
                        ? unsafe listxattr(cPath, buffer, size)
                        : unsafe llistxattr(cPath, buffer, size)
                }
            }
            return names(buffer)
        }

        public static func get(
            name: Swift::String,
            path: borrowing Path.Borrowed,
            followSymlinks: Bool = true
        ) throws(ISO_9945.Kernel.File.Attributes.Extended.Error) -> [UInt8] {
            try unsafe withCName(name) { cName throws(ISO_9945.Kernel.File.Attributes.Extended.Error) in
                try unsafe withCPath(path) { cPath throws(ISO_9945.Kernel.File.Attributes.Extended.Error) in
                    try unsafe probed { (buffer: UnsafeMutablePointer<UInt8>?, size) in
                        followSymlinks
                            ? unsafe getxattr(cPath, cName, buffer, size)
                            : unsafe lgetxattr(cPath, cName, buffer, size)
                    }
                }
            }
        }

        public static func set(
            name: Swift::String,
            value: UnsafeRawBufferPointer,
            path: borrowing Path.Borrowed,
            followSymlinks: Bool = true
        ) throws(ISO_9945.Kernel.File.Attributes.Extended.Error) {
            try unsafe withCName(name) { cName throws(ISO_9945.Kernel.File.Attributes.Extended.Error) in
                try unsafe withCPath(path) { cPath throws(ISO_9945.Kernel.File.Attributes.Extended.Error) in
                    let result =
                        followSymlinks
                        ? unsafe setxattr(cPath, cName, value.baseAddress, value.count, 0)
                        : unsafe lsetxattr(cPath, cName, value.baseAddress, value.count, 0)
                    guard result == 0 else { throw .current() }
                }
            }
        }

        public static func remove(
            name: Swift::String,
            path: borrowing Path.Borrowed,
            followSymlinks: Bool = true
        ) throws(ISO_9945.Kernel.File.Attributes.Extended.Error) {
            try unsafe withCName(name) { cName throws(ISO_9945.Kernel.File.Attributes.Extended.Error) in
                try unsafe withCPath(path) { cPath throws(ISO_9945.Kernel.File.Attributes.Extended.Error) in
                    let result =
                        followSymlinks
                        ? unsafe removexattr(cPath, cName)
                        : unsafe lremovexattr(cPath, cName)
                    guard result == 0 else { throw .current() }
                }
            }
        }
    }

    extension ISO_9945.Kernel.File.Attributes.Extended {

        public static func list(
            _ descriptor: borrowing ISO_9945.Kernel.Descriptor
        ) throws(ISO_9945.Kernel.File.Attributes.Extended.Error) -> [Swift::String] {
            let fd = descriptor._rawValue
            let buffer = try unsafe probed { (buffer: UnsafeMutablePointer<CChar>?, size) in
                unsafe flistxattr(fd, buffer, size)
            }
            return names(buffer)
        }

        public static func get(
            name: Swift::String,
            _ descriptor: borrowing ISO_9945.Kernel.Descriptor
        ) throws(ISO_9945.Kernel.File.Attributes.Extended.Error) -> [UInt8] {
            let fd = descriptor._rawValue
            return try unsafe withCName(name) { cName throws(ISO_9945.Kernel.File.Attributes.Extended.Error) in
                try unsafe probed { (buffer: UnsafeMutablePointer<UInt8>?, size) in
                    unsafe fgetxattr(fd, cName, buffer, size)
                }
            }
        }

        @unsafe
        public static func set(
            name: Swift::String,
            value: UnsafeRawBufferPointer,
            _ descriptor: borrowing ISO_9945.Kernel.Descriptor
        ) throws(ISO_9945.Kernel.File.Attributes.Extended.Error) {
            let fd = descriptor._rawValue
            try unsafe withCName(name) { cName throws(ISO_9945.Kernel.File.Attributes.Extended.Error) in
                guard unsafe fsetxattr(fd, cName, value.baseAddress, value.count, 0) == 0 else {
                    throw .current()
                }
            }
        }

        public static func remove(
            name: Swift::String,
            _ descriptor: borrowing ISO_9945.Kernel.Descriptor
        ) throws(ISO_9945.Kernel.File.Attributes.Extended.Error) {
            let fd = descriptor._rawValue
            try unsafe withCName(name) { cName throws(ISO_9945.Kernel.File.Attributes.Extended.Error) in
                guard unsafe fremovexattr(fd, cName) == 0 else { throw .current() }
            }
        }
    }

#endif
