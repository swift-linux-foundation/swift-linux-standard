#if os(Linux)
    public import Linux_Standard_Core

    extension Linux.Kernel.Event.Poll.Events {

        @inlinable
        public init(interest: Linux.Kernel.Event.Interest) {
            var events: Self = []
            if interest.contains(.read) {
                events.insert(.in)
                events.insert(.rdhup)
            }
            if interest.contains(.write) {
                events.insert(.out)
            }
            if interest.contains(.priority) {
                events.insert(.pri)
            }
            self = events
        }
    }

#endif
