#if os(Linux)

    public import Linux_Standard_Core
    public import ISO_9945_Core
    import ISO_9945_Kernel_Process
    public import Error

    extension Linux.Kernel.Process.Descriptor {

        public enum Error: Swift::Error, Sendable, Equatable, Hashable {

            case create(Error::Error.Code)
        }
    }

    extension Linux.Kernel.Process.Descriptor.Error: CustomStringConvertible {
        public var description: Swift::String {
            switch self {
            case .create(let code):
                return "process descriptor creation failed (\(code))"
            }
        }
    }

    extension Linux.Kernel.Process.Descriptor.Error {

        public var code: Error::Error.Code {
            switch self {
            case .create(let code): return code
            }
        }
    }

#endif
