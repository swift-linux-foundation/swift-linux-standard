public import Error_Primitives
public import Linux_Standard_Core

extension Linux.Kernel.File.Clone.Error {

    public enum Syscall: Swift.Error, Sendable {

        case platform(code: Error_Primitives.Error.Code, operation: Operation)
    }
}
