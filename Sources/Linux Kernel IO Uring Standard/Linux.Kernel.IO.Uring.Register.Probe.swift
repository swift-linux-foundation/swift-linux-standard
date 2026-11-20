#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Register {
        public struct Probe {
        }
    }

    extension Linux.Kernel.IO.Uring.Register.Probe {
        public static let register = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 8)
    }

    extension Linux.Kernel.IO.Uring.Register.Opcode {
        public static var probe: Linux.Kernel.IO.Uring.Register.Probe.Type {
            Linux.Kernel.IO.Uring.Register.Probe.self
        }
    }

#endif
