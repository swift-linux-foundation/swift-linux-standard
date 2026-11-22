#if os(Linux)

    public import Linux_Standard_Core
    public import Error

    extension Linux.Kernel.Timer.Descriptor {

        public enum Error: Swift::Error, Sendable, Equatable, Hashable {

            case create(Error::Error.Code)
        }
    }

    extension Linux.Kernel.Timer.Descriptor.Error: CustomStringConvertible {
        public var description: Swift::String {
            switch self {
            case .create(let code):
                return "timer descriptor creation failed (\(code))"
            }
        }
    }

    extension Linux.Kernel.Timer.Descriptor.Error {

        public var code: Error::Error.Code {
            switch self {
            case .create(let code): return code
            }
        }
    }

#endif
