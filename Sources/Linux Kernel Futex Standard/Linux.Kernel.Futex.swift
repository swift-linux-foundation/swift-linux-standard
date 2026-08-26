#if os(Linux)

    public import ISO_9945_Core
    public import Error
    public import Memory
    public import Path

    extension ISO_9945.Kernel {

        public struct Futex: Sendable {}
    }

#endif
