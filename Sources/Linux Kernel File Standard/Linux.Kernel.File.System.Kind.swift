#if os(Linux)

    public import ISO_9945_Core

    extension ISO_9945.Kernel.File.System.Kind {

        public static let ext4 = Self(rawValue: 0xEF53)

        public static let btrfs = Self(rawValue: 0x9123_683E)

        public static let xfs = Self(rawValue: 0x5846_5342)

        public static let tmpfs = Self(rawValue: 0x0102_1994)

        public static let proc = Self(rawValue: 0x9FA0)

        public static let sysfs = Self(rawValue: 0x6265_6572)

        public static let nfs = Self(rawValue: 0x6969)

        public static let cifs = Self(rawValue: 0xFF53_4D42)
    }

#endif
