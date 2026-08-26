public import Linux_Standard_Core

extension Linux.Kernel.File {

    public enum Clone: Sendable {}
}

#if os(Linux)

    @_spi(Syscall) public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    public import Error
    public import Path

    #if canImport(Glibc)
        internal import Glibc
        internal import Linux_Kernel_Shims
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Linux.Kernel.File.Clone.Capability {

        public static func probe(
            at path: borrowing Path.Borrowed
        ) throws(Linux.Kernel.File.Clone.Error.Syscall) -> Linux.Kernel.File.Clone.Capability {
            try unsafe path.withUnsafePointer {
                cString throws(Linux.Kernel.File.Clone.Error.Syscall) in
                var statfsBuf = statfs()
                let result = statfs(
                    UnsafeRawPointer(cString).assumingMemoryBound(to: CChar.self),
                    &statfsBuf
                )

                guard result == 0 else {
                    throw Linux.Kernel.File.Clone.Error.Syscall.platform(
                        code: .posix(errno),
                        operation: .statfs
                    )
                }

                let fsMagic = statfsBuf.f_type
                if fsMagic == 0x9123_683E || fsMagic == 0x5846_5342 {
                    return .reflink
                }

                return .none
            }
        }
    }

    extension Linux.Kernel.File.Clone.Metadata {

        public static func size(
            at path: borrowing Path.Borrowed
        ) throws(Linux.Kernel.File.Clone.Error.Syscall) -> Int {
            try unsafe path.withUnsafePointer {
                cString throws(Linux.Kernel.File.Clone.Error.Syscall) in
                var statBuf = Glibc.stat()
                let result = stat(
                    UnsafeRawPointer(cString).assumingMemoryBound(to: CChar.self),
                    &statBuf
                )

                guard result == 0 else {
                    throw Linux.Kernel.File.Clone.Error.Syscall.platform(
                        code: .posix(errno),
                        operation: .stat
                    )
                }

                return Int(statBuf.st_size)
            }
        }
    }

    private let _FICLONE: UInt = 0x4004_9409

    extension Linux.Kernel.File.Clone {

        public enum Ficlone {

            internal static func attempt(
                sourceFd: Int32,
                destinationFd: Int32
            ) throws(Linux.Kernel.File.Clone.Error.Syscall) -> Bool {
                let result = ioctl(destinationFd, _FICLONE, sourceFd)

                if result == 0 {
                    return true
                }

                let err = errno
                if err == EOPNOTSUPP || err == ENOTSUP || err == EINVAL || err == EXDEV {
                    return false
                }

                throw .platform(code: .posix(err), operation: .ficlone)
            }
        }

    }

    extension Linux.Kernel.File.Clone.Ficlone {

        public static func attempt(
            source: borrowing ISO_9945.Kernel.Descriptor,
            destination: borrowing ISO_9945.Kernel.Descriptor
        ) throws(Linux.Kernel.File.Clone.Error.Syscall) -> Bool {
            try attempt(sourceFd: source._rawValue, destinationFd: destination._rawValue)
        }
    }

    extension Linux.Kernel.File.Clone {

        public enum CopyRange {

            internal static func copy(
                sourceFd: Int32,
                destinationFd: Int32,
                length: Int
            ) throws(Linux.Kernel.File.Clone.Error.Syscall) {
                var remaining = ISO_9945.Kernel.File.Size(length)
                var srcOffset = ISO_9945.Kernel.File.Offset(0)
                var dstOffset = ISO_9945.Kernel.File.Offset(0)

                while remaining > .zero {
                    let copied: ISO_9945.Kernel.File.Size
                    do {
                        copied = try Linux.Kernel.Copy.Range.copy(
                            fromFd: sourceFd,
                            sourceOffset: &srcOffset,
                            toFd: destinationFd,
                            destOffset: &dstOffset,
                            length: remaining
                        )
                    } catch {
                        throw .platform(code: .posix(errno), operation: .copyFileRange)
                    }

                    if copied == .zero {
                        break
                    }

                    remaining -= copied
                }
            }
        }
    }

    extension Linux.Kernel.File.Clone.CopyRange {

        public static func copy(
            source: borrowing ISO_9945.Kernel.Descriptor,
            destination: borrowing ISO_9945.Kernel.Descriptor,
            length: Int
        ) throws(Linux.Kernel.File.Clone.Error.Syscall) {
            try copy(
                sourceFd: source._rawValue,
                destinationFd: destination._rawValue,
                length: length
            )
        }
    }

#endif
