#if os(Linux)
    public import System
    internal import Glibc

    extension System.Topology.NUMA {

        public static func discover() -> System.Topology.NUMA.State {
            let basePath = "/sys/devices/system/node"

            var statBuf = stat()
            guard stat(basePath, &statBuf) == 0 else {
                return .unavailable
            }

            guard let dir = opendir(basePath) else {
                return .unavailable
            }
            defer { closedir(dir) }

            var nodes: [System.Topology.NUMA.Node] = []

            while let entry = readdir(dir) {
                let name = withUnsafePointer(to: entry.pointee.d_name) { ptr in
                    Swift.String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
                }

                guard name.hasPrefix("node"),
                    let nodeID = Int(name.dropFirst(4))
                else {
                    continue
                }

                let cpulistPath = "\(basePath)/\(name)/cpulist"
                guard let cpus = parseCPUList(at: cpulistPath) else {
                    continue
                }

                nodes.append(
                    System.Topology.NUMA.Node(
                        id: nodeID,
                        cpus: cpus,
                        isSynthetic: false
                    )
                )
            }

            nodes.sort { $0.id < $1.id }

            switch nodes.count {
            case 0:
                return .unavailable

            case 1:
                return .uniformAccess

            default:
                return .nonUniform(nodes: nodes)
            }
        }

        private static func parseCPUList(at path: String) -> Set<Int>? {
            guard let file = fopen(path, "r") else {
                return nil
            }
            defer { fclose(file) }

            var buffer = [CChar](repeating: 0, count: 256)
            guard fgets(&buffer, Int32(buffer.count), file) != nil else {
                return nil
            }

            var content = Swift.String(cString: buffer)
            while content.last?.isWhitespace == true { content.removeLast() }
            while content.first?.isWhitespace == true { content.removeFirst() }
            return parseCPUListString(content)
        }

        private static func parseCPUListString(_ string: Swift.String) -> Set<Int> {
            var cpus = Set<Int>()

            for part in string.split(separator: ",") {
                let range = part.split(separator: "-")
                if range.count == 2,
                    let start = Int(range[0]),
                    let end = Int(range[1])
                {
                    for cpu in start...end {
                        cpus.insert(cpu)
                    }
                } else if let single = Int(part) {
                    cpus.insert(single)
                }
            }

            return cpus
        }
    }
#else
    public import System

    extension System.Topology.NUMA {
        public static func discover() -> System.Topology.NUMA.State {
            .unavailable
        }
    }
#endif
