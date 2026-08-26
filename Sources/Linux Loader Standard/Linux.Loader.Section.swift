#if os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android)

    public import Linux_Standard_Core
    public import Loader

    extension Linux_Standard_Core.Linux.Loader {

        public enum Section: Sendable {}
    }

    extension Linux_Standard_Core.Linux.Loader.Section {

        public typealias Name = Loader.Section.Name

        public typealias Bounds = Loader.Section.Bounds
    }

    extension Linux_Standard_Core.Linux.Loader.Section {

        public static func all(_ name: Name) -> [Bounds] {
            guard let sectionName = name.elf else {

                return []
            }

            return enumerateSections(named: sectionName)
        }

        private static func enumerateSections(named sectionName: StaticString) -> [Bounds] {

            return []
        }
    }

#endif
