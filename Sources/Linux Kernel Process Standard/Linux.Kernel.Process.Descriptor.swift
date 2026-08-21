#if os(Linux)

    @_spi(Syscall) public import ISO_9945_Core
    public import ISO_9945_Kernel_Process
    public import Error_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension ISO_9945.Kernel.Process {

        public struct Descriptor: ~Copyable, Sendable {

            @_spi(Syscall)
            public let descriptor: ISO_9945.Kernel.Descriptor

            @_spi(Syscall)
            @inlinable
            public init(descriptor: consuming ISO_9945.Kernel.Descriptor) {
                self.descriptor = descriptor
            }
        }
    }

    extension ISO_9945.Kernel.Process.Descriptor {

        public static func create(
            pid: ISO_9945.Kernel.Process.ID,
            flags: UInt32 = 0
        ) throws(ISO_9945.Kernel.Process.Descriptor.Error) -> ISO_9945.Kernel.Process.Descriptor {
            let fd = unsafe swift_pidfd_open(pid.rawValue, flags)
            guard fd >= 0 else {
                throw .create(.posix(errno))
            }
            return ISO_9945.Kernel.Process.Descriptor(
                descriptor: ISO_9945.Kernel.Descriptor(_rawValue: fd)
            )
        }
    }

    extension ISO_9945.Kernel.Descriptor {

        public init(_ processDescriptor: consuming ISO_9945.Kernel.Process.Descriptor) {
            self = processDescriptor.descriptor
        }
    }

    extension ISO_9945.Kernel.Process.Descriptor {

        public consuming func close() {
            _ = consume self
        }
    }

#endif
