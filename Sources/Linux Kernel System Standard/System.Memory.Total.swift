#if os(Linux)
    public import System_Primitives
    internal import Glibc

    extension System.Memory {

        public static var total: System.Memory.Capacity {
            guard let file = unsafe fopen("/proc/meminfo", "r") else {
                return System.Memory.Capacity(_unchecked: Cardinal(UInt(0)))
            }
            defer { unsafe fclose(file) }

            var buffer = [CChar](repeating: 0, count: 256)
            guard unsafe fgets(&buffer, Int32(buffer.count), file) != nil else {
                return System.Memory.Capacity(_unchecked: Cardinal(UInt(0)))
            }

            let line = unsafe String(cString: buffer)
            var bytes: UInt = 0
            for char in line.unicodeScalars {
                if char >= "0" && char <= "9" {
                    bytes = bytes &* 10 &+ UInt(char.value - 0x30)
                } else if bytes > 0 {
                    break
                }
            }

            bytes = bytes &* 1024

            return System.Memory.Capacity(_unchecked: Cardinal(bytes))
        }
    }
#else
    public import System_Primitives

    extension System.Memory {

        public static var total: System.Memory.Capacity {
            System.Memory.Capacity(_unchecked: Cardinal(UInt(0)))
        }
    }
#endif
