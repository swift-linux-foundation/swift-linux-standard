public import Linux_Standard_Core

extension Linux.Kernel.File.Clone {

    public enum Capability: Sendable, Equatable {

        case reflink

        case none
    }
}
