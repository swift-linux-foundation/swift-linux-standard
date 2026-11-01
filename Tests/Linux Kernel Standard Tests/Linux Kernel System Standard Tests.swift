#if os(Linux)

    import Testing

    @testable import Linux_Kernel_System_Standard

    @Suite
    struct `Linux Kernel System Standard Tests` {
        @Test
        func `core count is at least one and at most the logical count`() {
            let cores = Int(CPU.Core.count)
            #expect(cores >= 1)
            #expect(cores <= Int(CPU.Logical.count))
        }

        @Test
        func `capacity exceeds one mebibyte`() {
            #expect(Int(Memory.Physical.capacity) > 1024 * 1024)
        }

        @Test
        func `NUMA nodes each hold processors`() {
            if case .nonUniform(let nodes) = CPU.NUMA.state {
                for node in nodes {
                    #expect(!node.processors.isEmpty)
                }
            }
        }

        @Test
        func `the CPU list format expands ranges`() {
            #expect(Linux.Kernel.Sysfs.list(parsing: "0-3,8,10-11") == [0, 1, 2, 3, 8, 10, 11])
        }
    }

#endif
