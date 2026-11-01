#if os(Linux)

    public import Memory

    extension Memory.Physical {

        /// The installed memory in bytes, `MemTotal` in `/proc/meminfo`. A failed read reports zero.
        public static var capacity: Memory.Capacity {
            guard let line = Linux.Kernel.Sysfs.line(at: "/proc/meminfo"),
                line.hasPrefix("MemTotal:")
            else {
                return Memory.Capacity(_unchecked: Cardinal(0 as UInt))
            }

            let digits = line.unicodeScalars.filter { $0 >= "0" && $0 <= "9" }
            guard let kibibytes = UInt(Swift::String(Swift::String.UnicodeScalarView(digits))) else {
                return Memory.Capacity(_unchecked: Cardinal(0 as UInt))
            }

            let (bytes, overflow) = kibibytes.multipliedReportingOverflow(by: 1024)
            return Memory.Capacity(_unchecked: Cardinal(overflow ? UInt.max : bytes))
        }
    }

#endif
