#if os(Linux)

    @_spi(Syscall) public import ISO_9945_Core
    public import Error_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension ISO_9945.Kernel.Timer {

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

    extension ISO_9945.Kernel.Timer.Descriptor {

        public static func create(
            clockId: Int32? = nil,
            flags: Int32? = nil
        ) throws(ISO_9945.Kernel.Timer.Descriptor.Error) -> ISO_9945.Kernel.Timer.Descriptor {

            let fd = unsafe timerfd_create(
                clockId ?? Int32(CLOCK_MONOTONIC),
                flags ?? Int32(TFD_CLOEXEC)
            )
            guard fd >= 0 else {
                throw .create(.posix(errno))
            }
            return ISO_9945.Kernel.Timer.Descriptor(
                descriptor: ISO_9945.Kernel.Descriptor(_rawValue: fd)
            )
        }
    }

    extension ISO_9945.Kernel.Descriptor {

        public init(_ timerDescriptor: consuming ISO_9945.Kernel.Timer.Descriptor) {
            self = timerDescriptor.descriptor
        }
    }

    extension ISO_9945.Kernel.Timer.Descriptor {

        public consuming func close() {
            _ = consume self
        }
    }

#endif
