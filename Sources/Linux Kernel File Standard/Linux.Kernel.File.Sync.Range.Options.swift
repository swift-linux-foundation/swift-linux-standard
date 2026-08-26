#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    public import Error
    public import Memory
    public import Path

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension ISO_9945.Kernel.File {

        public struct Sync: Sendable {

            public struct Range: Sendable {

                public struct Options: OptionSet, Sendable {
                    public let rawValue: UInt32

                    public init(rawValue: UInt32) {
                        self.rawValue = rawValue
                    }

                    public static let waitBefore = Self(
                        rawValue: UInt32(SYNC_FILE_RANGE_WAIT_BEFORE)
                    )

                    public static let write = Self(rawValue: UInt32(SYNC_FILE_RANGE_WRITE))

                    public static let waitAfter = Self(rawValue: UInt32(SYNC_FILE_RANGE_WAIT_AFTER))
                }
            }
        }
    }

#endif
