#if os(Linux)

    public import Linux_Standard_Core
    public import Error_Primitives

    extension Linux.Kernel.Event.Poll {

        public enum Create {}
    }

#endif
