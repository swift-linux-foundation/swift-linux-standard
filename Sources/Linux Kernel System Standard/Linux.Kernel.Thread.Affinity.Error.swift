public import Error_Primitives
public import Linux_Standard_Core

extension Linux.Kernel.Thread.Affinity {

    public enum Error: Swift.Error, Sendable, Equatable, Hashable {

        case platform(Error_Primitives.Error.Code)
    }
}
