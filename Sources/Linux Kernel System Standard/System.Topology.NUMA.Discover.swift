#if os(Linux)
    public import System_Primitives
    internal import Glibc

    extension System.Topology.NUMA {

        public static func discover() -> System.Topology.NUMA.State {
            let basePath = "/sys/devices/system/node"

            var statBuf = stat()
            guard unsafe stat(basePath, &statBuf) == 0 else {
                return .unavailable
            }

            guard let dir = unsafe opendir(basePath) else {
                return .unavailable
            }
            defer { unsafe closedir(dir) }

            var nodes: [System.Topology.NUMA.Node] = []

            while let entry = unsafe readdir(dir) {
                let name = unsafe withUnsafePointer(to: entry.pointee.d_name) { ptr in
                    unsafe Swift::String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
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
            guard let file = unsafe fopen(path, "r") else {
                return nil
            }
            defer { unsafe fclose(file) }

            var buffer = [CChar](repeating: 0, count: 256)
            guard unsafe fgets(&buffer, Int32(buffer.count), file) != nil else {
                return nil
            }

            var content = Swift::String(decoding: buffer.prefix { $0 != 0 }.map(UTF8.CodeUnit.init(bitPattern:)), as: UTF8.self)
            while content.last?.isWhitespace == true { content.removeLast() }
            while content.first?.isWhitespace == true { content.removeFirst() }
            return parseCPUListString(content)
        }

        private static func parseCPUListString(_ string: Swift::String) -> Set<Int> {
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
    public import System_Primitives

    extension System.Topology.NUMA {
        public static func discover() -> System.Topology.NUMA.State {
            .unavailable
        }
    }
#endif
