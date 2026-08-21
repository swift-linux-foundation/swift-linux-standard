#if os(Linux)

    public import ISO_9945_Core
    public import Error_Primitives
    public import Memory_Primitives
    public import Path_Primitives

    extension ISO_9945.Kernel {

        public struct Futex: Sendable {}
    }

#endif
