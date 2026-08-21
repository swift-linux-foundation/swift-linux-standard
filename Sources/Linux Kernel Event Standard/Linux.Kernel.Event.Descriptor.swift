#if os(Linux)

    @_spi(Syscall) public import ISO_9945_Core
    public import Linux_Standard_Core
    public import Error_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension Linux.Kernel.Event {

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

    extension Linux.Kernel.Event.Descriptor {

        public static func create(
            value: UInt32 = 0,
            flags: Flags = .cloexec
        ) throws(Linux.Kernel.Event.Descriptor.Error) -> Linux.Kernel.Event.Descriptor {
            let fd = eventfd(value, flags.rawValue)
            guard fd >= 0 else {
                throw .create(.posix(errno))
            }
            return Linux.Kernel.Event.Descriptor(
                descriptor: ISO_9945.Kernel.Descriptor(_rawValue: fd)
            )
        }
    }

    extension Linux.Kernel.Event.Descriptor {

        public mutating func read() throws(Linux.Kernel.Event.Descriptor.Error) -> UInt64 {
            var value: UInt64 = 0
            #if canImport(Glibc)
                let result = unsafe Glibc.read(
                    descriptor._rawValue,
                    &value,
                    MemoryLayout<UInt64>.size
                )
            #elseif canImport(Musl)
                let result = unsafe Musl.read(
                    descriptor._rawValue,
                    &value,
                    MemoryLayout<UInt64>.size
                )
            #endif
            guard result == MemoryLayout<UInt64>.size else {
                let code = Error_Primitives.Error.Code.posix(errno)
                if code == .posix(EAGAIN) || code == .posix(EWOULDBLOCK) {
                    throw .wouldBlock
                }
                throw .read(code)
            }
            return value
        }

        public mutating func write(_ value: UInt64) throws(Linux.Kernel.Event.Descriptor.Error) {
            var val = value
            #if canImport(Glibc)
                let result = unsafe Glibc.write(
                    descriptor._rawValue,
                    &val,
                    MemoryLayout<UInt64>.size
                )
            #elseif canImport(Musl)
                let result = unsafe Musl.write(
                    descriptor._rawValue,
                    &val,
                    MemoryLayout<UInt64>.size
                )
            #endif
            guard result == MemoryLayout<UInt64>.size else {
                let code = Error_Primitives.Error.Code.posix(errno)
                if code == .posix(EAGAIN) || code == .posix(EWOULDBLOCK) {
                    throw .wouldBlock
                }
                throw .write(code)
            }
        }

        public func signal() {
            Linux.Kernel.Event.Descriptor.signal(rawDescriptor: descriptor._rawValue)
        }

        package static func signal(rawDescriptor fd: Int32) {
            var val: UInt64 = 1
            #if canImport(Glibc)
                let result = unsafe Glibc.write(fd, &val, MemoryLayout<UInt64>.size)
            #elseif canImport(Musl)
                let result = unsafe Musl.write(fd, &val, MemoryLayout<UInt64>.size)
            #endif
            if result < 0 {
                let code = Error_Primitives.Error.Code.posix(errno)
                if code == .posix(EAGAIN) || code == .posix(EWOULDBLOCK) || code == .posix(EBADF) {

                } else {
                    assertionFailure("eventfd signal failed: \(code)")
                }
            }
        }
    }

    extension ISO_9945.Kernel.Descriptor {

        public init(_ eventDescriptor: consuming Linux.Kernel.Event.Descriptor) {
            self = eventDescriptor.descriptor
        }
    }

    extension Linux.Kernel.Event.Descriptor {

        public consuming func close() {
            _ = consume self
        }
    }

#endif
