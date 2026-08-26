#if os(Linux)

    public import ISO_9945_Core
    public import System

    extension ISO_9945.Kernel.IO.Uring.Params.Submission {

        public struct Thread: Sendable, Equatable {

            public var cpu: System.Processor.ID

            public var idle: Duration

            public init(
                cpu: System.Processor.ID = .zero,
                idle: Duration = .zero
            ) {
                self.cpu = cpu
                self.idle = idle
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Params.Submission.Thread {

        internal init(cCpu: UInt32, cIdle: UInt32) {
            self.cpu = System.Processor.ID(_unchecked: Ordinal(UInt(cCpu)))
            self.idle = .milliseconds(Int(cIdle))
        }

        internal var cCpu: UInt32 {
            UInt32(cpu.underlying.rawValue)
        }

        internal var cIdle: UInt32 {
            let (seconds, attoseconds) = idle.components
            let ms = seconds * 1000 + attoseconds / 1_000_000_000_000_000
            return UInt32(clamping: ms)
        }
    }

#endif
