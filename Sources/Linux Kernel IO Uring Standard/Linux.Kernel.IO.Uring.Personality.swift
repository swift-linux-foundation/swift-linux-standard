#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public enum Personality {}
    }

    extension ISO_9945.Kernel.IO.Uring.Personality {

        public typealias ID = Tagged<ISO_9945.Kernel.IO.Uring.Personality, UInt16>
    }

    extension Tagged where Tag == ISO_9945.Kernel.IO.Uring.Personality, Underlying == UInt16 {

        public static var none: Self { Self(_unchecked: 0) }
    }

#endif
