#if os(Linux)

    public import ISO_9945_Core
    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension ISO_9945.Kernel.IO.Uring {

        public struct Params: Sendable, Equatable {

            public private(set) var sqEntries: ISO_9945.Kernel.IO.Uring.Submission.Count

            public private(set) var cqEntries: ISO_9945.Kernel.IO.Uring.Completion.Count

            public var flags: Setup.Options

            public var submission: Submission

            public private(set) var features: Features

            public private(set) var sqOff: ISO_9945.Kernel.IO.Uring.Submission.Queue.Offsets

            public private(set) var cqOff: ISO_9945.Kernel.IO.Uring.Completion.Queue.Offsets

            public init(
                flags: Setup.Options = [],
                submission: Submission = Submission()
            ) {
                self.sqEntries = ISO_9945.Kernel.IO.Uring.Submission.Count.zero
                self.cqEntries = ISO_9945.Kernel.IO.Uring.Completion.Count.zero
                self.flags = flags
                self.submission = submission
                self.features = Features(rawValue: 0)
                self.sqOff = ISO_9945.Kernel.IO.Uring.Submission.Queue.Offsets()
                self.cqOff = ISO_9945.Kernel.IO.Uring.Completion.Queue.Offsets()
            }

            internal init(_ cParams: io_uring_params) {
                self.sqEntries = ISO_9945.Kernel.IO.Uring.Submission.Count(
                    _unchecked: Cardinal(UInt(cParams.sq_entries))
                )
                self.cqEntries = ISO_9945.Kernel.IO.Uring.Completion.Count(
                    _unchecked: Cardinal(UInt(cParams.cq_entries))
                )
                self.flags = Setup.Options(rawValue: cParams.flags)
                self.submission = Submission(
                    thread: Submission.Thread(
                        cCpu: cParams.sq_thread_cpu,
                        cIdle: cParams.sq_thread_idle
                    )
                )
                self.features = Features(rawValue: cParams.features)
                self.sqOff = ISO_9945.Kernel.IO.Uring.Submission.Queue.Offsets(cParams.sq_off)
                self.cqOff = ISO_9945.Kernel.IO.Uring.Completion.Queue.Offsets(cParams.cq_off)
            }

        }
    }

    extension ISO_9945.Kernel.IO.Uring.Params {

        internal var cValue: io_uring_params {
            var params = io_uring_params()
            params.flags = flags.rawValue
            params.sq_thread_cpu = submission.thread.cCpu
            params.sq_thread_idle = submission.thread.cIdle
            return params
        }
    }

#endif
