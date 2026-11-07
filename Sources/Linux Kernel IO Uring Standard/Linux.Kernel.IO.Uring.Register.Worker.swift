#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register {

        public struct Worker {

            public static var affinity: Affinity.Type { Affinity.self }

            public static let max = Opcode(rawValue: 19)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {

        public static var worker: ISO_9945.Kernel.IO.Uring.Register.Worker.Type {
            ISO_9945.Kernel.IO.Uring.Register.Worker.self
        }
    }

#endif
