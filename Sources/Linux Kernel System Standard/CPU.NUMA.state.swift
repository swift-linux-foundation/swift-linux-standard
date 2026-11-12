#if os(Linux)

    public import CPU
    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension CPU.NUMA {

        /// The NUMA nodes under `/sys/devices/system/node`, each with its `cpulist`.
        public static var state: State {
            let base = "/sys/devices/system/node"

            guard let directory = unsafe opendir(base) else {
                return .unavailable
            }
            defer { unsafe closedir(directory) }

            var nodes: [Node] = []

            while let entry = unsafe readdir(directory) {
                let name = unsafe withUnsafePointer(to: entry.pointee.d_name) { pointer in
                    unsafe Swift::String(cString: UnsafeRawPointer(pointer).assumingMemoryBound(to: CChar.self))
                }

                guard name.hasPrefix("node"),
                    let number = UInt(name.dropFirst(4)),
                    let processors = Linux.Kernel.Sysfs.list(at: "\(base)/\(name)/cpulist")
                else {
                    continue
                }

                nodes.append(
                    Node(
                        id: Node.ID(_unchecked: Ordinal(number)),
                        processors: Set(
                            processors.compactMap { UInt(exactly: $0) }.map { CPU.Logical.ID(_unchecked: Ordinal($0)) }
                        )
                    )
                )
            }

            nodes.sort { $0.id < $1.id }

            switch nodes.count {
            case 0:
                return .unavailable

            case 1:
                return .uniform

            default:
                return .nonUniform(nodes: nodes)
            }
        }
    }

#endif
