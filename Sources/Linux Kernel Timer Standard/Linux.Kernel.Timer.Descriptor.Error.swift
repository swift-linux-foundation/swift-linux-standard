#if os(Linux)

    public import ISO_9945_Core
    public import Error

    extension ISO_9945.Kernel.Timer.Descriptor {

        public enum Error: Swift.Error, Sendable, Equatable, Hashable {

            case create(Error.Error.Code)
        }
    }

    extension ISO_9945.Kernel.Timer.Descriptor.Error: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            case .create(let code):
                return "timer descriptor creation failed (\(code))"
            }
        }
    }

    extension ISO_9945.Kernel.Timer.Descriptor.Error {

        public var code: Error.Error.Code {
            switch self {
            case .create(let code): return code
            }
        }
    }

#endif
