public import Linux_Standard_Core

extension Linux.Kernel.Thread {

    public enum Affinity: Sendable {}
}

#if os(Linux) || os(Android) || os(OpenBSD)

    public import Error

    internal import Linux_Kernel_Shims

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #elseif canImport(Bionic)
        internal import Bionic
    #endif

    extension Linux.Kernel.Thread.Affinity {

        public static func setMask(
            tid: Int32 = 0,
            cores: Set<Int>
        ) throws(Linux.Kernel.Thread.Affinity.Error) {
            var mask = cpu_set_t()

            unsafe withUnsafeMutablePointer(to: &mask) { ptr in
                let rawPtr = unsafe UnsafeMutableRawPointer(ptr)
                unsafe rawPtr.initializeMemory(
                    as: UInt8.self,
                    repeating: 0,
                    count: MemoryLayout<cpu_set_t>.size
                )
            }

            for cpu in cores {
                unsafe withUnsafeMutablePointer(to: &mask) { maskPtr in
                    let cpusPerLong = MemoryLayout<UInt>.size * 8
                    let index = cpu / cpusPerLong
                    let offset = cpu % cpusPerLong
                    unsafe maskPtr.withMemoryRebound(
                        to: UInt.self,
                        capacity: MemoryLayout<cpu_set_t>.size / MemoryLayout<UInt>.size
                    ) { longs in
                        unsafe longs[index] |= UInt(1) << offset
                    }
                }
            }

            let result = unsafe withUnsafePointer(to: &mask) { maskPtr -> Int32 in
                unsafe swift_sched_setaffinity(
                    tid,
                    MemoryLayout<cpu_set_t>.size,
                    UnsafeRawPointer(maskPtr)
                )
            }

            guard result == 0 else {
                throw .platform(.posix(errno))
            }
        }
    }

#endif
