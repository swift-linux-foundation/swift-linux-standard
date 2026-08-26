public import Error
public import Linux_Standard_Core

extension Linux.Kernel.File.Clone.Error {

    public enum Syscall: Swift.Error, Sendable {

        case platform(code: Error.Error.Code, operation: Operation)
    }
}
