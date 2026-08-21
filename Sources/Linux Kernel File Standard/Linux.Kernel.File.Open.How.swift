#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension ISO_9945.Kernel.File.Open {

        public struct How: @unchecked Sendable {
            internal var cValue: open_how

            public init(
                access: ISO_9945.Kernel.File.Open.Access = .readOnly,
                options: ISO_9945.Kernel.File.Open.Options = [],
                mode: ISO_9945.Kernel.File.Permissions = .none,
                resolve: ISO_9945.Kernel.File.Open.Resolve = []
            ) {
                self.cValue = open_how()
                self.cValue.flags = UInt64(access.rawValue | options.rawValue)
                self.cValue.mode = UInt64(mode.rawValue)
                self.cValue.resolve = resolve.rawValue
            }
        }
    }

    extension ISO_9945.Kernel.File.Open.How {

        public var access: ISO_9945.Kernel.File.Open.Access {
            get {
                switch Int32(cValue.flags & 0x3) {
                case 1: .writeOnly
                case 2: .readWrite
                default: .readOnly
                }
            }
            set {
                cValue.flags = (cValue.flags & ~0x3) | UInt64(newValue.rawValue)
            }
        }

        public var options: ISO_9945.Kernel.File.Open.Options {
            get { ISO_9945.Kernel.File.Open.Options(rawValue: Int32(cValue.flags & ~0x3)) }
            set {
                cValue.flags = UInt64(newValue.rawValue) | (cValue.flags & 0x3)
            }
        }

        public var mode: ISO_9945.Kernel.File.Permissions {
            get { ISO_9945.Kernel.File.Permissions(rawValue: UInt16(cValue.mode)) }
            set { cValue.mode = UInt64(newValue.rawValue) }
        }

        public var resolve: ISO_9945.Kernel.File.Open.Resolve {
            get { ISO_9945.Kernel.File.Open.Resolve(rawValue: cValue.resolve) }
            set { cValue.resolve = newValue.rawValue }
        }
    }

#endif
