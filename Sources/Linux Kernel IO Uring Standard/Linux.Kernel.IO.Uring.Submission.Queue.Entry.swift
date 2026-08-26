#if os(Linux)

    public import ISO_9945_Kernel_Socket_Address
    public import ISO_9945_Kernel_Socket
    public import Error
    public import Memory
    public import Memory_Map
    public import Linux_Kernel_File_Standard
    public import Linux_Kernel_Pipe_Standard
    public import Linux_Kernel_Event_Standard
    public import Linux_Kernel_Futex_Standard
    public import Linux_Kernel_Socket_Standard
    public import Linux_Kernel_Memory_Standard
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

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue {

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

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {

        public var opcode: ISO_9945.Kernel.IO.Uring.Opcode {
            get { ISO_9945.Kernel.IO.Uring.Opcode(rawValue: cValue.opcode) }
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

        public var priority: ISO_9945.Kernel.IO.Priority {
            get { ISO_9945.Kernel.IO.Priority(rawValue: cValue.ioprio) }
            set { cValue.ioprio = newValue.rawValue }
        }

        @usableFromInline
        internal var transferOptions: ISO_9945.Kernel.IO.Uring.Socket.Transfer.Options {
            get { .init(rawValue: cValue.ioprio) }
            set { cValue.ioprio = newValue.rawValue }
        }

        public var offset: ISO_9945.Kernel.IO.Uring.Offset {
            get { ISO_9945.Kernel.IO.Uring.Offset(cValue.off) }
            set { cValue.off = newValue.underlying }
        }

        @usableFromInline
        internal var addr: UInt64 {
            get { cValue.addr }
            set { cValue.addr = newValue }
        }

        public var len: ISO_9945.Kernel.IO.Uring.Length {
            get { ISO_9945.Kernel.IO.Uring.Length(cValue.len) }
            set { cValue.len = newValue.underlying }
        }

        public var data: ISO_9945.Kernel.IO.Uring.Operation.Data {
            get { ISO_9945.Kernel.IO.Uring.Operation.Data(_unchecked: cValue.user_data) }
            set { cValue.user_data = newValue.underlying }
        }

        public var personality: ISO_9945.Kernel.IO.Uring.Personality.ID {
            get { ISO_9945.Kernel.IO.Uring.Personality.ID(_unchecked: cValue.personality) }
            set { cValue.personality = newValue.underlying }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {

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
        internal var syncRangeFlags: ISO_9945.Kernel.File.Sync.Range.Options {
            get { ISO_9945.Kernel.File.Sync.Range.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        @usableFromInline
        internal var pipeCreateFlags: ISO_9945.Kernel.Pipe.Options {
            get { ISO_9945.Kernel.Pipe.Options(rawValue: Int32(bitPattern: cValue.rw_flags)) }
            set { cValue.rw_flags = UInt32(bitPattern: newValue.rawValue) }
        }

        @usableFromInline
        internal var installFlags: ISO_9945.Kernel.IO.Uring.Fixed.Install.Options {
            get { ISO_9945.Kernel.IO.Uring.Fixed.Install.Options(rawValue: cValue.rw_flags) }
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
        internal var shutdownMode: ISO_9945.Kernel.Socket.Shutdown.Mode {
            get { ISO_9945.Kernel.Socket.Shutdown.Mode(rawValue: Int32(bitPattern: cValue.len)) }
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

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {

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
        internal var _bufferIndex: ISO_9945.Kernel.IO.Uring.Buffer.Index {
            get { ISO_9945.Kernel.IO.Uring.Buffer.Index(rawValue: cValue.buf_index) }
            set { cValue.buf_index = newValue.rawValue }
        }

        @usableFromInline
        internal var _bufferGroup: ISO_9945.Kernel.IO.Uring.Buffer.Group {
            get { ISO_9945.Kernel.IO.Uring.Buffer.Group(rawValue: cValue.buf_group) }
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
            get { withUnsafePointer(to: cValue) { swift_io_uring_sqe_get_addr3($0) } }
            set {
                withUnsafeMutablePointer(to: &cValue) { swift_io_uring_sqe_set_addr3($0, newValue) }
            }
        }

        @usableFromInline
        internal var commandOpcode: UInt32 {
            get { withUnsafePointer(to: cValue) { swift_io_uring_sqe_get_cmd_op($0) } }
            set {
                withUnsafeMutablePointer(to: &cValue) {
                    swift_io_uring_sqe_set_cmd_op($0, newValue)
                }
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {

        @usableFromInline
        internal var spliceFlags: ISO_9945.Kernel.Pipe.Splice.Options {
            get { ISO_9945.Kernel.Pipe.Splice.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        @usableFromInline
        internal var renameFlags: ISO_9945.Kernel.File.Rename.Options {
            get { ISO_9945.Kernel.File.Rename.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        @usableFromInline
        internal var messageRingFlags: ISO_9945.Kernel.IO.Uring.Message.Options {
            get { ISO_9945.Kernel.IO.Uring.Message.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        @usableFromInline
        internal var futexFlags: ISO_9945.Kernel.Futex.Options {
            get { ISO_9945.Kernel.Futex.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        @usableFromInline
        internal mutating func setXattrDisposition(
            _ disposition: ISO_9945.Kernel.IO.Uring.File.Xattr.Disposition
        ) {
            cValue.rw_flags = disposition.rawBits
        }

        @usableFromInline
        internal var waitidFlags: ISO_9945.Kernel.IO.Uring.Wait.Options {
            get { ISO_9945.Kernel.IO.Uring.Wait.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        @usableFromInline
        internal var pollEvents: Linux.Kernel.Event.Poll.Events {
            get { Linux.Kernel.Event.Poll.Events(rawValue: cValue.poll32_events) }
            set { cValue.poll32_events = newValue.rawValue }
        }

        @usableFromInline
        internal var pollOptions: ISO_9945.Kernel.IO.Uring.Poll.Options {
            get { ISO_9945.Kernel.IO.Uring.Poll.Options(rawValue: cValue.len) }
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
        internal var socketProtocol: ISO_9945.Kernel.Socket.`Protocol` {
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
            clock: ISO_9945.Kernel.IO.Uring.Clock,
            options: ISO_9945.Kernel.IO.Uring.Timeout.Options = []
        ) {
            cValue.rw_flags = clock.timeoutBits | options.rawValue
        }

        @usableFromInline
        internal mutating func setWaitidProcess(_ id: ISO_9945.Kernel.Process.ID) {
            cValue.fd = id.rawValue
        }

        @usableFromInline @unsafe
        internal mutating func setAddr(_ pointer: UnsafeRawPointer?) {
            cValue.addr = unsafe UInt64(UInt(bitPattern: pointer))
        }

        @usableFromInline
        internal mutating func setAddr(_ data: ISO_9945.Kernel.IO.Uring.Operation.Data) {
            cValue.addr = data.underlying
        }

        @usableFromInline @unsafe
        internal mutating func setOffset(_ pointer: UnsafeRawPointer?) {
            cValue.off = unsafe UInt64(UInt(bitPattern: pointer))
        }

        @usableFromInline @unsafe
        internal mutating func setAddr3(_ pointer: UnsafeRawPointer) {
            let raw = unsafe UInt64(UInt(bitPattern: pointer))
            withUnsafeMutablePointer(to: &cValue) { swift_io_uring_sqe_set_addr3($0, raw) }
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
        internal mutating func setMessageTarget(_ data: ISO_9945.Kernel.IO.Uring.Operation.Data) {
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
