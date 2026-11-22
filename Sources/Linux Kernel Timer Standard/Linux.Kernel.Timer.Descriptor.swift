#if os(Linux)

    public import Linux_Standard_Core
    @_spi(Syscall) public import ISO_9945_Core
    import Error

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension Linux.Kernel.Timer {

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

    extension Linux.Kernel.Timer.Descriptor {

        public static func create(
            clockId: Int32? = nil,
            flags: Int32? = nil
        ) throws(Linux.Kernel.Timer.Descriptor.Error) -> Linux.Kernel.Timer.Descriptor {

            let fd = timerfd_create(
                clockId ?? Int32(CLOCK_MONOTONIC),
                flags ?? Int32(TFD_CLOEXEC)
            )
            guard fd >= 0 else {
                throw .create(.posix(errno))
            }
            return Linux.Kernel.Timer.Descriptor(
                descriptor: ISO.`9945`.Kernel.Descriptor(_rawValue: fd)
            )
        }
    }

    extension ISO.`9945`.Kernel.Descriptor {

        public init(_ timerDescriptor: consuming Linux.Kernel.Timer.Descriptor) {
            self = timerDescriptor.descriptor
        }
    }

    extension Linux.Kernel.Timer.Descriptor {

        public consuming func close() {
            _ = consume self
        }
    }

#endif
