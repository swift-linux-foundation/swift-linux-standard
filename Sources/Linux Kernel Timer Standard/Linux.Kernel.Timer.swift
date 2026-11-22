#if os(Linux)

    public import Linux_Standard_Core
    extension Linux.Kernel {

        public enum Timer: Sendable {}
    }

#endif
