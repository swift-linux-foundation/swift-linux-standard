#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public struct Sync {

            public static var file: File.Type { File.self }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {

        public static var sync: ISO_9945.Kernel.IO.Uring.Sync.Type {
            ISO_9945.Kernel.IO.Uring.Sync.self
        }
    }

#endif
