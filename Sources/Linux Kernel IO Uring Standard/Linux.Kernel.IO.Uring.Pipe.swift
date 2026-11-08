#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {
        public struct Pipe {
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Pipe {
        public static let splice = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 30)

        public static let tee = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 33)

        public static let create = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 62)

        public static let fixedDescriptorIn: UInt32 = 0x8000_0000
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        public static var pipe: ISO_9945.Kernel.IO.Uring.Pipe.Type {
            ISO_9945.Kernel.IO.Uring.Pipe.self
        }
    }

#endif
