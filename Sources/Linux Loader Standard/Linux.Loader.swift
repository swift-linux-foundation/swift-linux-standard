#if os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android)

    @_exported public import Linux_Standard_Core
    @_exported public import Loader_Primitives

    extension Linux_Standard_Core.Linux {

        public enum Loader: Sendable {}
    }

#endif
