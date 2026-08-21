#if os(Linux)

    public import ISO_9945_Core
    public import Linux_Standard_Core
    public import Error_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension Linux.Kernel.Event.Poll {

        public struct Event: @unchecked Sendable {

            internal var cValue: epoll_event

            public init(events: Events = [], data: Linux.Kernel.Event.Poll.Data = .zero) {
                self.cValue = epoll_event()
                self.cValue.events = events.rawValue
                self.cValue.data.u64 = data.underlying
            }
        }
    }

    extension Linux.Kernel.Event.Poll.Event {

        public var events: Linux.Kernel.Event.Poll.Events {
            get { Linux.Kernel.Event.Poll.Events(rawValue: cValue.events) }
            set { cValue.events = newValue.rawValue }
        }

        public var data: Linux.Kernel.Event.Poll.Data {
            get { Linux.Kernel.Event.Poll.Data(_unchecked: cValue.data.u64) }
            set { cValue.data.u64 = newValue.underlying }
        }
    }

    extension Linux.Kernel.Event.Poll.Event {

        internal init(_ cEvent: epoll_event) {
            self.cValue = cEvent
        }
    }

    extension Linux.Kernel.Event.Poll.Event: Equatable {
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.cValue.events == rhs.cValue.events && lhs.cValue.data.u64 == rhs.cValue.data.u64
        }
    }

    extension Linux.Kernel.Event.Poll.Event: Hashable {
        public func hash(into hasher: inout Hasher) {
            hasher.combine(cValue.events)
            hasher.combine(cValue.data.u64)
        }
    }

#endif
