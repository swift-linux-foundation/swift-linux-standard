#if os(Linux) || os(Android) || os(OpenBSD)

    extension Linux.Kernel.Random {

        /// The failures one `getrandom(2)` call reports.
        public enum Error: Swift.Error, Sendable, Hashable {

            /// `EINTR`: a signal interrupted the call before any byte was written.
            case interrupted

            /// `EAGAIN`: the entropy pool is not yet initialized.
            case entropyNotReady

            case systemError(Int32)
        }
    }

#endif
