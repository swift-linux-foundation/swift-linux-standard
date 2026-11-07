#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register {

        public struct Probe {

            public static let register = Opcode(rawValue: 8)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {

        public static var probe: ISO_9945.Kernel.IO.Uring.Register.Probe.Type {
            ISO_9945.Kernel.IO.Uring.Register.Probe.self
        }
    }

#endif
