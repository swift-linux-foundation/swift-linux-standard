#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension ISO_9945.Kernel.File.Statx {

        public struct Timestamp: @unchecked Sendable, Equatable {
            internal var cValue: statx_timestamp

            internal init(_ cValue: statx_timestamp) {
                self.cValue = cValue
            }

            public init(seconds: Int64 = 0, nanoseconds: UInt32 = 0) {
                self.cValue = statx_timestamp()
                self.cValue.tv_sec = seconds
                self.cValue.tv_nsec = nanoseconds
            }
        }
    }

    extension ISO_9945.Kernel.File.Statx.Timestamp {

        public var seconds: Int64 {
            cValue.tv_sec
        }

        public var nanoseconds: UInt32 {
            cValue.tv_nsec
        }
    }

    extension ISO_9945.Kernel.File.Statx.Timestamp {
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.cValue.tv_sec == rhs.cValue.tv_sec && lhs.cValue.tv_nsec == rhs.cValue.tv_nsec
        }
    }

#endif
