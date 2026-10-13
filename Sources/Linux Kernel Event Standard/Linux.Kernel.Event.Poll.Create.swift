#if os(Linux)

    public import Linux_Standard_Core
    import Error

    extension Linux.Kernel.Event.Poll {

        public enum Create {}
    }

#endif
