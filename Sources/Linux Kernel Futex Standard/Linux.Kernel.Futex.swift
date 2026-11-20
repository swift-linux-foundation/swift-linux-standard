#if os(Linux)

    public import Linux_Standard_Core
    public import ISO_9945_Core
    import Error
    import Memory
    import Path

    extension Linux.Kernel {

        public struct Futex: Sendable {}
    }

#endif
