#if os(Linux)

public import Kernel_Process_Primitives

extension Kernel.Process {
    /// Process wait operations (waitid, waitpid).
    public struct Wait: Sendable {}
}

#endif
