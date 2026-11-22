#if os(Linux)

    public import Linux_Standard_Core
    import ISO_9945_Core
    extension Linux.Kernel.Futex {

        public struct Wait: Sendable {}
    }

#endif
