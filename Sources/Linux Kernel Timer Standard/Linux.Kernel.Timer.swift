#if os(Linux)

    public import Linux_Standard_Core
    public import ISO_9945_Core
    extension Linux.Kernel {

        public enum Timer: Sendable {}
    }

#endif
