#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {

        public enum Personality {}
    }

    extension Linux.Kernel.IO.Uring.Personality {

        public typealias ID = Tagged<Linux.Kernel.IO.Uring.Personality, UInt16>
    }

    extension Tagged where Tag == Linux.Kernel.IO.Uring.Personality, Underlying == UInt16 {

        public static var none: Self { Self(_unchecked: 0) }
    }

#endif
