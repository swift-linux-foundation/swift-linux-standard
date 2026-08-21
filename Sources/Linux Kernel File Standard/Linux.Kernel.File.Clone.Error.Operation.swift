public import Linux_Standard_Core

extension Linux.Kernel.File.Clone.Error {

    public enum Operation: Swift.String, Sendable, Equatable {

        case statfs

        case stat

        case ficlone

        case copyFileRange
    }
}
