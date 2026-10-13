public import Error
public import Linux_Standard_Core

extension Linux.Kernel.Copy {

    public enum Error: Swift::Error, Sendable, Equatable, Hashable {

        case invalidDescriptor

        case crossDevice

        case unsupported

        case noSpace

        case io

        case permissionDenied

        case exists

        case notFound

        case platform(code: Error::Error.Code)
    }
}
