#if os(Linux)

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Linux.Kernel {

        /// Reads the one-line text files under `/sys` and `/proc`.
        internal enum Sysfs {}
    }

    extension Linux.Kernel.Sysfs {

        /// The first line of the file at `path`, trimmed, or `nil` when it cannot be read.
        internal static func line(at path: Swift::String) -> Swift::String? {
            guard let file = unsafe fopen(path, "r") else {
                return nil
            }
            defer { unsafe fclose(file) }

            var buffer = [CChar](repeating: 0, count: 4096)
            guard unsafe fgets(&buffer, Int32(buffer.count), file) != nil else {
                return nil
            }

            var content = Swift::String(
                decoding: buffer.prefix { $0 != 0 }.map(UTF8.CodeUnit.init(bitPattern:)),
                as: UTF8.self
            )
            while content.last?.isWhitespace == true { content.removeLast() }
            while content.first?.isWhitespace == true { content.removeFirst() }
            return content
        }

        /// The integer the file at `path` holds.
        internal static func integer(at path: Swift::String) -> Int? {
            line(at: path).flatMap { Int($0) }
        }

        /// The kernel's CPU list format (`0-3,8,10-11`) read from the file at `path`.
        internal static func list(at path: Swift::String) -> Set<Int>? {
            line(at: path).map(list(parsing:))
        }

        internal static func list(parsing string: Swift::String) -> Set<Int> {
            var values = Set<Int>()
            for part in string.split(separator: ",") {
                let range = part.split(separator: "-")
                if range.count == 2, let start = Int(range[0]), let end = Int(range[1]), start <= end {
                    (start...end).forEach { value in
                        values.insert(value)
                    }
                } else if let single = Int(part) {
                    values.insert(single)
                }
            }
            return values
        }
    }

#endif
