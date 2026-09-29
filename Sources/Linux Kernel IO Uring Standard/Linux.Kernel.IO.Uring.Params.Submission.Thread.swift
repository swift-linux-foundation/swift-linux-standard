#if os(Linux)

    public import ISO_9945_Core
    public import System

    extension ISO_9945.Kernel.IO.Uring.Params.Submission {

        public struct Thread: Sendable, Equatable {

            public var cpu: Int

            public var idle: Duration

            public init(
                cpu: Int = 0,
                idle: Duration = .zero
            ) {
                self.cpu = cpu
                self.idle = idle
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Params.Submission.Thread {

        internal init(cCpu: UInt32, cIdle: UInt32) {
            guard let cpu = Int(exactly: cCpu) else {
                preconditionFailure("CPU identifier is not representable as Int")
            }
            self.cpu = cpu
            self.idle = .milliseconds(Int(cIdle))
        }

        internal var cCpu: UInt32 {
            guard let value = UInt32(exactly: cpu) else {
                preconditionFailure("CPU identifier must be representable as UInt32")
            }
            return value
        }

        internal var cIdle: UInt32 {
            let (seconds, attoseconds) = idle.components
            let ms = seconds * 1000 + attoseconds / 1_000_000_000_000_000
            return UInt32(clamping: ms)
        }
    }

#endif
