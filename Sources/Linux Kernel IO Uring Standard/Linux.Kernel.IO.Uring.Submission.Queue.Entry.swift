#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Kernel_Socket_Address
    import ISO_9945_Kernel_Socket
    import Error
    public import Memory
    public import Linux_Kernel_File_Standard
    public import Linux_Kernel_Pipe_Standard
    public import Linux_Kernel_Event_Standard
    public import Linux_Kernel_Futex_Standard
    public import Linux_Kernel_Socket_Standard
    import Linux_Kernel_Memory_Standard
    public import ISO_9945_Kernel_File
    public import ISO_9945_Kernel_Process
    @_spi(Syscall) public import ISO_9945_Core

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension Linux.Kernel.IO.Uring.Submission.Queue {

        public struct Entry: ~Copyable {

            internal var cValue: io_uring_sqe

            public init() {
                self.cValue = io_uring_sqe()
            }

            internal init(_ cValue: io_uring_sqe) {
                self.cValue = cValue
            }
        }
    }

    extension Linux.Kernel.IO.Uring.Submission.Queue.Entry {

        public var opcode: Linux.Kernel.IO.Uring.Opcode {
            get { Linux.Kernel.IO.Uring.Opcode(rawValue: cValue.opcode) }
            set { cValue.opcode = newValue.rawValue }
        }

        public var flags: Options {
            get { Options(rawValue: cValue.flags) }
            set { cValue.flags = newValue.rawValue }
        }

        @usableFromInline
        internal var opFlags: Int32 {
            get { Int32(bitPattern: cValue.rw_flags) }
            set { cValue.rw_flags = UInt32(bitPattern: newValue) }
        }

        public var priority: Linux.Kernel.IO.Priority {
            get { Linux.Kernel.IO.Priority(rawValue: cValue.ioprio) }
            set { cValue.ioprio = newValue.rawValue }
        }

        @usableFromInline
        internal var transferOptions: Linux.Kernel.IO.Uring.Socket.Transfer.Options {
            get { .init(rawValue: cValue.ioprio) }
            set { cValue.ioprio = newValue.rawValue }
        }

        public var offset: Linux.Kernel.IO.Uring.Offset {
            get { Linux.Kernel.IO.Uring.Offset(cValue.off) }
            set { cValue.off = newValue.underlying }
        }

        @usableFromInline
        internal var addr: UInt64 {
            get { cValue.addr }
            set { cValue.addr = newValue }
        }

        public var len: Linux.Kernel.IO.Uring.Length {
            get { Linux.Kernel.IO.Uring.Length(cValue.len) }
            set { cValue.len = newValue.underlying }
        }

        public var data: Linux.Kernel.IO.Uring.Operation.Data {
            get { Linux.Kernel.IO.Uring.Operation.Data(_unchecked: cValue.user_data) }
            set { cValue.user_data = newValue.underlying }
        }

        public var personality: Linux.Kernel.IO.Uring.Personality.ID {
            get { Linux.Kernel.IO.Uring.Personality.ID(_unchecked: cValue.personality) }
            set { cValue.personality = newValue.underlying }
        }
    }

    extension Linux.Kernel.IO.Uring.Submission.Queue.Entry {

        @usableFromInline
        internal var atFlags: ISO_9945.Kernel.File.At.Options {
            get { ISO_9945.Kernel.File.At.Options(rawValue: Int32(bitPattern: cValue.rw_flags)) }
            set { cValue.rw_flags = UInt32(bitPattern: newValue.rawValue) }
        }

        @usableFromInline
        internal var fileAdvice: ISO_9945.Kernel.File.Advice {
            get { ISO_9945.Kernel.File.Advice(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        @usableFromInline
        internal var memoryAdvice: Memory.Map.Advice {
            get { Memory.Map.Advice(rawValue: Int32(bitPattern: cValue.rw_flags)) }
            set { cValue.rw_flags = UInt32(bitPattern: newValue.rawValue) }
        }

        @usableFromInline
        internal var syncRangeFlags: Linux.Kernel.File.Sync.Range.Options {
            get { Linux.Kernel.File.Sync.Range.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        @usableFromInline
        internal var pipeCreateFlags: Linux.Kernel.Pipe.Options {
            get { Linux.Kernel.Pipe.Options(rawValue: Int32(bitPattern: cValue.rw_flags)) }
            set { cValue.rw_flags = UInt32(bitPattern: newValue.rawValue) }
        }

        @usableFromInline
        internal var installFlags: Linux.Kernel.IO.Uring.Fixed.Install.Options {
            get { Linux.Kernel.IO.Uring.Fixed.Install.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        @usableFromInline
        internal var filePermissions: ISO_9945.Kernel.File.Permissions {
            get {
                ISO_9945.Kernel.File.Permissions(rawValue: UInt16(truncatingIfNeeded: cValue.len))
            }
            set { cValue.len = UInt32(newValue.rawValue) }
        }

        @usableFromInline
        internal var shutdownMode: Linux.Kernel.Socket.Shutdown.Mode {
            get { Linux.Kernel.Socket.Shutdown.Mode(rawValue: Int32(bitPattern: cValue.len)) }
            set { cValue.len = UInt32(bitPattern: newValue.rawValue) }
        }

        @usableFromInline
        internal var listenBacklog: Int32 {
            get { Int32(bitPattern: UInt32(truncatingIfNeeded: cValue.off)) }
            set { cValue.off = UInt64(UInt32(bitPattern: newValue)) }
        }

        @usableFromInline
        internal var addressLength: UInt32 {
            get { UInt32(truncatingIfNeeded: cValue.off) }
            set { cValue.off = UInt64(newValue) }
        }

        @usableFromInline
        internal var messageFlags: ISO_9945.Kernel.Socket.Message.Options {
            get {
                ISO_9945.Kernel.Socket.Message.Options(rawValue: Int32(bitPattern: cValue.rw_flags))
            }
            set { cValue.rw_flags = UInt32(bitPattern: newValue.rawValue) }
        }

        @usableFromInline
        internal var acceptFlags: ISO_9945.Kernel.Socket.Options {
            get { ISO_9945.Kernel.Socket.Options(rawValue: Int32(bitPattern: cValue.rw_flags)) }
            set { cValue.rw_flags = UInt32(bitPattern: newValue.rawValue) }
        }
    }

    extension Linux.Kernel.IO.Uring.Submission.Queue.Entry {

        @usableFromInline
        internal static let fsyncDatasync: Int32 = Int32(IORING_FSYNC_DATASYNC)

        @usableFromInline
        internal var _fd: Int32 {
            get { cValue.fd }
            set { cValue.fd = newValue }
        }

        @usableFromInline
        internal var _rawLength: UInt32 {
            get { cValue.len }
            set { cValue.len = newValue }
        }

        @usableFromInline
        internal var _rawOffset: UInt64 {
            get { cValue.off }
            set { cValue.off = newValue }
        }

        @usableFromInline
        internal var _bufferIndex: Linux.Kernel.IO.Uring.Buffer.Index {
            get { Linux.Kernel.IO.Uring.Buffer.Index(rawValue: cValue.buf_index) }
            set { cValue.buf_index = newValue.rawValue }
        }

        @usableFromInline
        internal var _bufferGroup: Linux.Kernel.IO.Uring.Buffer.Group {
            get { Linux.Kernel.IO.Uring.Buffer.Group(rawValue: cValue.buf_group) }
            set { cValue.buf_group = newValue.rawValue }
        }

        @usableFromInline
        internal mutating func setSpliceSource(_ descriptor: borrowing ISO_9945.Kernel.Descriptor) {
            cValue.splice_fd_in = descriptor._rawValue
        }

        @usableFromInline
        internal mutating func setEpollDescriptor(
            _ descriptor: borrowing ISO_9945.Kernel.Descriptor
        ) {
            cValue.off = UInt64(UInt32(bitPattern: descriptor._rawValue))
        }

        @usableFromInline
        internal var _addr3: UInt64 {
            get { withUnsafePointer(to: cValue) { unsafe swift_io_uring_sqe_get_addr3($0) } }
            set {
                withUnsafeMutablePointer(to: &cValue) { unsafe swift_io_uring_sqe_set_addr3($0, newValue) }
            }
        }

        @usableFromInline
        internal var commandOpcode: UInt32 {
            get { withUnsafePointer(to: cValue) { unsafe swift_io_uring_sqe_get_cmd_op($0) } }
            set {
                withUnsafeMutablePointer(to: &cValue) {
                    unsafe swift_io_uring_sqe_set_cmd_op($0, newValue)
                }
            }
        }
    }

    extension Linux.Kernel.IO.Uring.Submission.Queue.Entry {

        @usableFromInline
        internal var spliceFlags: Linux.Kernel.Pipe.Splice.Options {
            get { Linux.Kernel.Pipe.Splice.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        @usableFromInline
        internal var renameFlags: Linux.Kernel.File.Rename.Options {
            get { Linux.Kernel.File.Rename.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        @usableFromInline
        internal var messageRingFlags: Linux.Kernel.IO.Uring.Message.Options {
            get { Linux.Kernel.IO.Uring.Message.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        @usableFromInline
        internal var futexFlags: Linux.Kernel.Futex.Options {
            get { Linux.Kernel.Futex.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        @usableFromInline
        internal mutating func setXattrDisposition(
            _ disposition: Linux.Kernel.IO.Uring.File.Xattr.Disposition
        ) {
            cValue.rw_flags = disposition.rawBits
        }

        @usableFromInline
        internal var waitidFlags: Linux.Kernel.IO.Uring.Wait.Options {
            get { Linux.Kernel.IO.Uring.Wait.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        @usableFromInline
        internal var pollEvents: Linux.Kernel.Event.Poll.Events {
            get { Linux.Kernel.Event.Poll.Events(rawValue: cValue.poll32_events) }
            set { cValue.poll32_events = newValue.rawValue }
        }

        @usableFromInline
        internal var pollOptions: Linux.Kernel.IO.Uring.Poll.Options {
            get { Linux.Kernel.IO.Uring.Poll.Options(rawValue: cValue.len) }
            set { cValue.len = newValue.rawValue }
        }

        @usableFromInline
        internal var waitidKind: ISO_9945.Kernel.Process.Wait.Kind {
            get { ISO_9945.Kernel.Process.Wait.Kind(rawValue: Int32(bitPattern: cValue.len)) }
            set { cValue.len = UInt32(bitPattern: newValue.rawValue) }
        }

        @usableFromInline
        internal var waitidOptions: ISO_9945.Kernel.Process.Wait.Options {
            get {
                ISO_9945.Kernel.Process.Wait.Options(rawValue: Int32(bitPattern: cValue.file_index))
            }
            set { cValue.file_index = UInt32(bitPattern: newValue.rawValue) }
        }

        @usableFromInline
        internal var epollOperation: Linux.Kernel.Event.Poll.Operation {
            get { Linux.Kernel.Event.Poll.Operation(rawValue: Int32(bitPattern: cValue.len)) }
            set { cValue.len = UInt32(bitPattern: newValue.rawValue) }
        }

        @usableFromInline
        internal var epollMaxEvents: Int32 {
            get { Int32(bitPattern: cValue.len) }
            set { cValue.len = UInt32(bitPattern: newValue) }
        }

        @usableFromInline
        internal var socketDomain: ISO_9945.Kernel.Socket.Address.Family {
            get { ISO_9945.Kernel.Socket.Address.Family(rawValue: cValue.fd) }
            set { cValue.fd = newValue.rawValue }
        }

        @usableFromInline
        internal var socketKind: ISO_9945.Kernel.Socket.Kind {
            get { ISO_9945.Kernel.Socket.Kind(rawValue: Int32(truncatingIfNeeded: cValue.off)) }
            set { cValue.off = UInt64(UInt32(bitPattern: newValue.rawValue)) }
        }

        @usableFromInline
        internal var socketProtocol: Linux.Kernel.Socket.`Protocol` {
            get { .init(rawValue: Int32(bitPattern: cValue.len)) }
            set { cValue.len = UInt32(bitPattern: newValue.rawValue) }
        }

        @usableFromInline
        internal var socketFlags: ISO_9945.Kernel.Socket.Options {
            get { ISO_9945.Kernel.Socket.Options(rawValue: Int32(bitPattern: cValue.rw_flags)) }
            set { cValue.rw_flags = UInt32(bitPattern: newValue.rawValue) }
        }

        @usableFromInline
        internal mutating func configureTimeout(
            clock: Linux.Kernel.IO.Uring.Clock,
            options: Linux.Kernel.IO.Uring.Timeout.Options = []
        ) {
            cValue.rw_flags = clock.timeoutBits | options.rawValue
        }

        @usableFromInline
        internal mutating func setWaitidProcess(_ id: ISO_9945.Kernel.Process.ID) {
            cValue.fd = id.rawValue
        }

        @usableFromInline @unsafe
        internal mutating func setAddr(_ pointer: UnsafeRawPointer?) {
            cValue.addr = UInt64(UInt(bitPattern: pointer))
        }

        @usableFromInline
        internal mutating func setAddr(_ data: Linux.Kernel.IO.Uring.Operation.Data) {
            cValue.addr = data.underlying
        }

        @usableFromInline @unsafe
        internal mutating func setOffset(_ pointer: UnsafeRawPointer?) {
            cValue.off = UInt64(UInt(bitPattern: pointer))
        }

        @usableFromInline @unsafe
        internal mutating func setAddr3(_ pointer: UnsafeRawPointer) {
            let raw = UInt64(UInt(bitPattern: pointer))
            withUnsafeMutablePointer(to: &cValue) { unsafe swift_io_uring_sqe_set_addr3($0, raw) }
        }

        @usableFromInline
        internal var targetDirectoryFd: Int32 {
            get { Int32(bitPattern: cValue.len) }
            set { cValue.len = UInt32(bitPattern: newValue) }
        }

        @usableFromInline
        internal var messageValue: UInt32 {
            get { cValue.len }
            set { cValue.len = newValue }
        }

        @usableFromInline
        internal var messageRingFd: Int32 {
            get { cValue.fd }
            set { cValue.fd = newValue }
        }

        @usableFromInline
        internal mutating func setMessageTarget(_ data: Linux.Kernel.IO.Uring.Operation.Data) {
            cValue.off = data.underlying
        }

        @usableFromInline
        internal var bufferCount: Int32 {
            get { cValue.fd }
            set { cValue.fd = newValue }
        }

        @usableFromInline
        internal var bufferStartID: UInt16 {
            get { UInt16(truncatingIfNeeded: cValue.off) }
            set { cValue.off = UInt64(newValue) }
        }
    }

#endif
