#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_Signal
    public import Error

    extension ISO_9945.Kernel.Signal.Descriptor {

        public enum Error: Swift.Error, Sendable, Equatable, Hashable {

            case create(Error.Error.Code)
        }
    }

    extension ISO_9945.Kernel.Signal.Descriptor.Error: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            case .create(let code):
                return "signal descriptor creation failed (\(code))"
            }
        }
    }

    extension ISO_9945.Kernel.Signal.Descriptor.Error {

        public var code: Error.Error.Code {
            switch self {
            case .create(let code): return code
            }
        }
    }

#endif
