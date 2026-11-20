#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {
        public struct Sync {
        }
    }

    extension Linux.Kernel.IO.Uring.Sync {
        public static var file: File.Type { File.self }
    }

    extension Linux.Kernel.IO.Uring.Opcode {
        public static var sync: Linux.Kernel.IO.Uring.Sync.Type {
            Linux.Kernel.IO.Uring.Sync.self
        }
    }

#endif
