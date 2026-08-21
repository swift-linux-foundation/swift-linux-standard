#if os(Linux)
    public import Linux_Standard_Core
    public import Error_Primitives

    extension Linux.Kernel.Event.Descriptor {

        public enum Error: Swift.Error, Sendable, Equatable, Hashable {

            case create(Error_Primitives.Error.Code)

            case read(Error_Primitives.Error.Code)

            case write(Error_Primitives.Error.Code)

            case wouldBlock
        }
    }

    extension Linux.Kernel.Event.Descriptor.Error: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            case .create(let code):
                return "event descriptor creation failed (\(code))"

            case .read(let code):
                return "event descriptor read failed (\(code))"

            case .write(let code):
                return "event descriptor write failed (\(code))"

            case .wouldBlock:
                return "operation would block"
            }
        }
    }

    extension Linux.Kernel.Event.Descriptor.Error {

        public var code: Error_Primitives.Error.Code? {
            switch self {
            case .create(let code): return code
            case .read(let code): return code
            case .write(let code): return code
            case .wouldBlock: return nil
            }
        }
    }

#endif
