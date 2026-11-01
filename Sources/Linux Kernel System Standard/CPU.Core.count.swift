#if os(Linux)

    public import CPU

    extension CPU.Core {

        /// The physical cores: the distinct (`physical_package_id`, `core_id`) pairs of the
        /// online CPUs under `/sys/devices/system/cpu`. Reports one core when `/sys` does not
        /// describe the topology.
        public static var count: Count {
            let base = "/sys/devices/system/cpu"

            guard let online = Linux.Kernel.Sysfs.list(at: "\(base)/online") else {
                return Count(_unchecked: Cardinal(1 as UInt))
            }

            var cores = Set<[Int]>()
            for cpu in online {
                let topology = "\(base)/cpu\(cpu)/topology"
                guard let core = Linux.Kernel.Sysfs.integer(at: "\(topology)/core_id") else {
                    continue
                }
                let package = Linux.Kernel.Sysfs.integer(at: "\(topology)/physical_package_id") ?? 0
                cores.insert([package, core])
            }

            guard let count = UInt(exactly: cores.count), count > 0 else {
                return Count(_unchecked: Cardinal(1 as UInt))
            }
            return Count(_unchecked: Cardinal(count))
        }
    }

#endif
