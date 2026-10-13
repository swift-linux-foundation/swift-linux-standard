#if os(Linux)

    public import ISO_9945_Core
    import Error
    import Memory
    import Path

    extension ISO_9945.Kernel {

        public struct Futex: Sendable {}
    }

#endif
