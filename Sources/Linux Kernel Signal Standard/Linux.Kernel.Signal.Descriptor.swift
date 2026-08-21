#if os(Linux)

    @_spi(Syscall) public import ISO_9945_Core
    @_spi(Syscall) public import ISO_9945_Kernel_Signal
    public import Error_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension ISO_9945.Kernel.Signal {

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

    extension ISO_9945.Kernel.Signal.Descriptor {

        public static func create(
            mask: borrowing ISO_9945.Kernel.Signal.Set,
            flags: Int32? = nil
        ) throws(ISO_9945.Kernel.Signal.Descriptor.Error) -> ISO_9945.Kernel.Signal.Descriptor {

            let resolvedFlags = flags ?? Int32(SFD_CLOEXEC)

            let fd = unsafe mask.withUnsafeRawPointer { raw in
                unsafe signalfd(-1, raw.assumingMemoryBound(to: sigset_t.self), resolvedFlags)
            }
            guard fd >= 0 else {
                throw .create(.posix(errno))
            }
            return ISO_9945.Kernel.Signal.Descriptor(
                descriptor: ISO_9945.Kernel.Descriptor(_rawValue: fd)
            )
        }
    }

    extension ISO_9945.Kernel.Descriptor {

        public init(_ signalDescriptor: consuming ISO_9945.Kernel.Signal.Descriptor) {
            self = signalDescriptor.descriptor
        }
    }

    extension ISO_9945.Kernel.Signal.Descriptor {

        public consuming func close() {
            _ = consume self
        }
    }

#endif
