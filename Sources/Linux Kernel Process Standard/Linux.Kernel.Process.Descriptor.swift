#if os(Linux)

    public import Linux_Standard_Core
    @_spi(Syscall) public import ISO_9945_Core
    import ISO_9945_Kernel_Process
    import Error

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension Linux.Kernel.Process {

        public struct Descriptor: ~Copyable, Sendable {

            @_spi(Syscall)
            public let descriptor: ISO.`9945`.Kernel.Descriptor

            @_spi(Syscall)
            @inlinable
            public init(descriptor: consuming ISO.`9945`.Kernel.Descriptor) {
                self.descriptor = descriptor
            }
        }
    }

    extension Linux.Kernel.Process.Descriptor {

        public static func create(
            pid: ISO.`9945`.Kernel.Process.ID,
            flags: UInt32 = 0
        ) throws(Linux.Kernel.Process.Descriptor.Error) -> Linux.Kernel.Process.Descriptor {
            let fd = swift_pidfd_open(pid.rawValue, flags)
            guard fd >= 0 else {
                throw .create(.posix(errno))
            }
            return Linux.Kernel.Process.Descriptor(
                descriptor: ISO.`9945`.Kernel.Descriptor(_rawValue: fd)
            )
        }
    }

    extension ISO.`9945`.Kernel.Descriptor {

        public init(_ processDescriptor: consuming Linux.Kernel.Process.Descriptor) {
            self = processDescriptor.descriptor
        }
    }

    extension Linux.Kernel.Process.Descriptor {

        public consuming func close() {
            _ = consume self
        }
    }

#endif
