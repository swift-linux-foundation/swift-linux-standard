#if os(Linux)

    public import ISO_9945_Kernel_Process
    public import ISO_9945_Kernel_Socket_Address
    public import ISO_9945_Kernel_Socket
    public import Error_Primitives
    public import Memory_Primitives
    public import Memory_Map_Primitives
    public import Linux_Kernel_File_Standard
    public import Linux_Kernel_Pipe_Standard
    public import Linux_Kernel_Event_Standard
    public import Linux_Kernel_Futex_Standard
    public import Linux_Kernel_Socket_Standard
    public import Linux_Kernel_System_Standard
    public import Linux_Kernel_Memory_Standard
    public import ISO_9945_Kernel_File
    public import ISO_9945_Kernel_Signal
    public import ISO_9945_Core

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {

        @inlinable
        public mutating func nop(data: ISO_9945.Kernel.IO.Uring.Operation.Data) {
            self = .init()
            self.opcode = .nop
            self.data = data
        }

        @inlinable @unsafe
        public mutating func read(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            buffer: UnsafeMutableRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .read.standard
            target.apply(to: &self)
            unsafe self.setAddr(buffer)
            self.len = length
            self.offset = offset
            self.data = data
        }

        @inlinable @unsafe
        public mutating func write(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            buffer: UnsafeRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .write.standard
            target.apply(to: &self)
            unsafe self.setAddr(buffer)
            self.len = length
            self.offset = offset
            self.data = data
        }

        @inlinable
        public mutating func cancel(
            target: ISO_9945.Kernel.IO.Uring.Operation.Data,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .cancel.async
            self.setAddr(target)
            self.data = data
        }

        @inlinable
        public mutating func fsync(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            datasync: Bool,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .sync.file.standard
            target.apply(to: &self)
            if datasync {
                self.opFlags = Self.fsyncDatasync
            }
            self.data = data
        }

        @inlinable
        public mutating func close(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .close
            target.apply(to: &self)
            self.data = data
        }

        @inlinable @unsafe
        public mutating func accept(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            addr: UnsafeMutablePointer<ISO_9945.Kernel.Socket.Address.Storage>?,
            length: UnsafeMutablePointer<UInt32>?,
            flags: ISO_9945.Kernel.Socket.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.accept
            target.apply(to: &self)
            unsafe self.setAddr(addr)
            unsafe self.setOffset(length)
            self.acceptFlags = flags
            self.data = data
        }

        @inlinable @unsafe
        public mutating func connect(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            address: UnsafePointer<ISO_9945.Kernel.Socket.Address.Storage>,
            length: UInt32,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.connect
            target.apply(to: &self)
            unsafe self.setAddr(address)
            self.offset = ISO_9945.Kernel.IO.Uring.Offset(UInt64(length))
            self.data = data
        }

        @inlinable @unsafe
        public mutating func send(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            buffer: UnsafeRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            flags: ISO_9945.Kernel.Socket.Message.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.send
            target.apply(to: &self)
            unsafe self.setAddr(buffer)
            self.len = length
            self.messageFlags = flags
            self.data = data
        }

        @inlinable @unsafe
        public mutating func recv(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            buffer: UnsafeMutableRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            flags: ISO_9945.Kernel.Socket.Message.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.receive
            target.apply(to: &self)
            unsafe self.setAddr(buffer)
            self.len = length
            self.messageFlags = flags
            self.data = data
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {

        @inlinable @unsafe
        public mutating func read(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            vectors: UnsafeBufferPointer<ISO_9945.Kernel.IO.Vector.Segment>,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .read.vectored.standard
            target.apply(to: &self)
            unsafe self.setAddr(vectors.baseAddress)
            self._rawLength = UInt32(vectors.count)
            self.offset = offset
            self.data = data
        }

        @inlinable @unsafe
        public mutating func write(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            vectors: UnsafeBufferPointer<ISO_9945.Kernel.IO.Vector.Segment>,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .write.vectored.standard
            target.apply(to: &self)
            unsafe self.setAddr(vectors.baseAddress)
            self._rawLength = UInt32(vectors.count)
            self.offset = offset
            self.data = data
        }

        @inlinable @unsafe
        public mutating func read(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            buffer: UnsafeMutableRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            bufferIndex: ISO_9945.Kernel.IO.Uring.Buffer.Index,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .read.fixed
            target.apply(to: &self)
            unsafe self.setAddr(buffer)
            self.len = length
            self.offset = offset
            self._bufferIndex = bufferIndex
            self.data = data
        }

        @inlinable @unsafe
        public mutating func write(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            buffer: UnsafeRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            bufferIndex: ISO_9945.Kernel.IO.Uring.Buffer.Index,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .write.fixed
            target.apply(to: &self)
            unsafe self.setAddr(buffer)
            self.len = length
            self.offset = offset
            self._bufferIndex = bufferIndex
            self.data = data
        }

        @inlinable @unsafe
        public mutating func read(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            vectors: UnsafeBufferPointer<ISO_9945.Kernel.IO.Vector.Segment>,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            bufferIndex: ISO_9945.Kernel.IO.Uring.Buffer.Index,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .read.vectored.fixed
            target.apply(to: &self)
            unsafe self.setAddr(vectors.baseAddress)
            self._rawLength = UInt32(vectors.count)
            self.offset = offset
            self._bufferIndex = bufferIndex
            self.data = data
        }

        @inlinable @unsafe
        public mutating func write(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            vectors: UnsafeBufferPointer<ISO_9945.Kernel.IO.Vector.Segment>,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            bufferIndex: ISO_9945.Kernel.IO.Uring.Buffer.Index,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .write.vectored.fixed
            target.apply(to: &self)
            unsafe self.setAddr(vectors.baseAddress)
            self._rawLength = UInt32(vectors.count)
            self.offset = offset
            self._bufferIndex = bufferIndex
            self.data = data
        }

        @inlinable
        public mutating func read(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            length: ISO_9945.Kernel.IO.Uring.Length,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            bufferGroup: ISO_9945.Kernel.IO.Uring.Buffer.Group,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .read.multishot
            target.apply(to: &self)
            self.len = length
            self.offset = offset
            self._bufferGroup = bufferGroup
            self.flags.insert(.bufferSelect)
            self.data = data
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {

        @inlinable
        public mutating func splice(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            source: borrowing ISO_9945.Kernel.Descriptor,
            offsets: (
                input: ISO_9945.Kernel.IO.Uring.Offset, output: ISO_9945.Kernel.IO.Uring.Offset
            ),
            length: ISO_9945.Kernel.IO.Uring.Length,
            flags: ISO_9945.Kernel.Pipe.Splice.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .pipe.splice
            target.apply(to: &self)
            self.setSpliceSource(source)
            self.addr = offsets.input.underlying
            self.offset = offsets.output
            self.len = length
            self.spliceFlags = flags
            self.data = data
        }

        @inlinable
        public mutating func tee(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            source: borrowing ISO_9945.Kernel.Descriptor,
            length: ISO_9945.Kernel.IO.Uring.Length,
            flags: ISO_9945.Kernel.Pipe.Splice.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .pipe.tee
            target.apply(to: &self)
            self.setSpliceSource(source)
            self.len = length
            self.spliceFlags = flags
            self.data = data
        }

        @inlinable
        public mutating func ftruncate(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            length: ISO_9945.Kernel.IO.Uring.Offset,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.ftruncate
            target.apply(to: &self)

            self.offset = length
            self.data = data
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {

        @inlinable @unsafe
        public mutating func openat(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            access: ISO_9945.Kernel.File.Open.Access = .readOnly,
            options: ISO_9945.Kernel.File.Open.Options = [],
            mode: ISO_9945.Kernel.File.Permissions = .none,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.openat
            target.apply(to: &self)
            unsafe self.setAddr(path)

            self.opFlags = access.rawValue | options.rawValue
            self.filePermissions = mode
            self.data = data
        }

        @inlinable @unsafe
        public mutating func openat2(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            how: UnsafePointer<ISO_9945.Kernel.File.Open.How>,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.openat2
            target.apply(to: &self)
            unsafe self.setAddr(path)
            self._rawLength = UInt32(MemoryLayout<ISO_9945.Kernel.File.Open.How>.size)
            unsafe self.setOffset(how)
            self.data = data
        }

        @inlinable @unsafe
        public mutating func statx(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            flags: ISO_9945.Kernel.File.At.Options,
            mask: ISO_9945.Kernel.File.Statx.Mask,
            buffer: UnsafeMutablePointer<ISO_9945.Kernel.File.Statx>,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.statx
            target.apply(to: &self)
            unsafe self.setAddr(path)
            self.atFlags = flags
            self._rawLength = mask.rawValue
            unsafe self.setOffset(buffer)
            self.data = data
        }

        @inlinable @unsafe
        public mutating func renameat(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            oldPath: UnsafePointer<CChar>,
            newDirFd: Int32,
            newPath: UnsafePointer<CChar>,
            flags: ISO_9945.Kernel.File.Rename.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.renameat
            target.apply(to: &self)
            unsafe self.setAddr(oldPath)
            self._rawLength = UInt32(bitPattern: newDirFd)
            unsafe self.setOffset(newPath)
            self.renameFlags = flags
            self.data = data
        }

        @inlinable @unsafe
        public mutating func unlinkat(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            flags: ISO_9945.Kernel.File.At.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.unlinkat
            target.apply(to: &self)
            unsafe self.setAddr(path)
            self.atFlags = flags
            self.data = data
        }

        @inlinable @unsafe
        public mutating func mkdirat(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            mode: UInt32,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.mkdirat
            target.apply(to: &self)
            unsafe self.setAddr(path)
            self._rawLength = mode
            self.data = data
        }

        @inlinable @unsafe
        public mutating func symlinkat(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            linkTarget: UnsafePointer<CChar>,
            linkPath: UnsafePointer<CChar>,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.symlinkat
            target.apply(to: &self)
            unsafe self.setAddr(linkTarget)
            unsafe self.setOffset(linkPath)
            self.data = data
        }

        @inlinable @unsafe
        public mutating func linkat(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            oldPath: UnsafePointer<CChar>,
            newDirFd: Int32,
            newPath: UnsafePointer<CChar>,
            flags: ISO_9945.Kernel.File.At.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.linkat
            target.apply(to: &self)
            unsafe self.setAddr(oldPath)
            self._rawLength = UInt32(bitPattern: newDirFd)
            unsafe self.setOffset(newPath)
            self.atFlags = flags
            self.data = data
        }

        @inlinable
        public mutating func fallocate(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            mode: ISO_9945.Kernel.IO.Uring.File.Allocate.Mode,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            length: UInt64,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.fallocate
            target.apply(to: &self)

            self.addr = length
            self._rawLength = UInt32(bitPattern: mode.rawBits)
            self.offset = offset
            self.data = data
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {

        @inlinable
        public mutating func socket(
            domain: ISO_9945.Kernel.Socket.Address.Family,
            kind: ISO_9945.Kernel.Socket.Kind,
            protocol: ISO_9945.Kernel.Socket.`Protocol` = .auto,
            flags: ISO_9945.Kernel.Socket.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.create
            self.socketDomain = domain
            self.socketFlags = flags
            self.socketProtocol = `protocol`
            self.socketKind = kind
            self.data = data
        }

        @inlinable @unsafe
        public mutating func bind(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            address: UnsafePointer<ISO_9945.Kernel.Socket.Address.Storage>,
            length: UInt32,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.bind
            target.apply(to: &self)
            unsafe self.setAddr(address)
            self.addressLength = length
            self.data = data
        }

        @inlinable
        public mutating func listen(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            backlog: Int32,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.listen
            target.apply(to: &self)
            self.listenBacklog = backlog
            self.data = data
        }

        @inlinable @unsafe
        public mutating func send(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            message: UnsafePointer<ISO_9945.Kernel.Socket.Message.Header>,
            flags: ISO_9945.Kernel.Socket.Message.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.message.send
            target.apply(to: &self)
            unsafe self.setAddr(message)
            self._rawLength = 1
            self.messageFlags = flags
            self.data = data
        }

        @inlinable @unsafe
        public mutating func recv(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            message: UnsafeMutablePointer<ISO_9945.Kernel.Socket.Message.Header>,
            flags: ISO_9945.Kernel.Socket.Message.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.message.receive
            target.apply(to: &self)
            unsafe self.setAddr(message)
            self._rawLength = 1
            self.messageFlags = flags
            self.data = data
        }

        @inlinable @unsafe
        public mutating func send(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            buffer: UnsafeRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            flags: ISO_9945.Kernel.Socket.Message.Options,
            transfer: ISO_9945.Kernel.IO.Uring.Socket.Transfer.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .send.zero.copy
            target.apply(to: &self)
            unsafe self.setAddr(buffer)
            self.len = length
            self.messageFlags = flags
            self.transferOptions = transfer
            self.data = data
        }

        @inlinable @unsafe
        public mutating func send(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            message: UnsafePointer<ISO_9945.Kernel.Socket.Message.Header>,
            flags: ISO_9945.Kernel.Socket.Message.Options,
            transfer: ISO_9945.Kernel.IO.Uring.Socket.Transfer.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .send.zero.msg
            target.apply(to: &self)
            unsafe self.setAddr(message)
            self._rawLength = 1
            self.messageFlags = flags
            self.transferOptions = transfer
            self.data = data
        }

        @inlinable
        public mutating func shutdown(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            how: ISO_9945.Kernel.Socket.Shutdown.Mode,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.shutdown
            target.apply(to: &self)
            self.shutdownMode = how
            self.data = data
        }

        @inlinable @unsafe
        public mutating func epoll(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            descriptor: borrowing ISO_9945.Kernel.Descriptor,
            operation: Linux.Kernel.Event.Poll.Operation,
            event: UnsafeMutablePointer<Linux.Kernel.Event.Poll.Event>?,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .epoll.ctl
            target.apply(to: &self)
            unsafe self.setAddr(event)
            self.epollOperation = operation
            self.setEpollDescriptor(descriptor)
            self.data = data
        }

        @inlinable @unsafe
        public mutating func epoll(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            events: UnsafeMutablePointer<Linux.Kernel.Event.Poll.Event>,
            maxEvents: Int32,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .epoll.wait
            target.apply(to: &self)
            unsafe self.setAddr(events)
            self.epollMaxEvents = maxEvents
            self.data = data
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {

        @inlinable @unsafe
        public mutating func timeout(
            after timespec: UnsafePointer<Linux.Kernel.Time.Specification>,
            count: UInt32 = 0,
            clock: ISO_9945.Kernel.IO.Uring.Clock = .monotonic,
            multishot: Bool = false,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .timeout.standard
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            unsafe self.setAddr(timespec)
            self._rawLength = count
            self.configureTimeout(clock: clock, options: multishot ? .multishot : [])
            self.data = data
        }

        @inlinable @unsafe
        public mutating func timeout(
            deadline timespec: UnsafePointer<Linux.Kernel.Time.Specification>,
            count: UInt32 = 0,
            clock: ISO_9945.Kernel.IO.Uring.Clock = .monotonic,
            multishot: Bool = false,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .timeout.standard
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            unsafe self.setAddr(timespec)
            self._rawLength = count
            let options: ISO_9945.Kernel.IO.Uring.Timeout.Options =
                multishot ? [.absolute, .multishot] : .absolute
            self.configureTimeout(clock: clock, options: options)
            self.data = data
        }

        @inlinable
        public mutating func timeout(
            remove target: ISO_9945.Kernel.IO.Uring.Operation.Data,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .timeout.remove
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            self.setAddr(target)
            self.data = data
        }

        @inlinable @unsafe
        public mutating func timeout(
            link timespec: UnsafePointer<Linux.Kernel.Time.Specification>,
            clock: ISO_9945.Kernel.IO.Uring.Clock = .monotonic,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .timeout.link
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            unsafe self.setAddr(timespec)
            self._rawLength = 1
            self.configureTimeout(clock: clock)
            self.data = data
        }

        @inlinable @unsafe
        public mutating func timeout(
            linkDeadline timespec: UnsafePointer<Linux.Kernel.Time.Specification>,
            clock: ISO_9945.Kernel.IO.Uring.Clock = .monotonic,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .timeout.link
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            unsafe self.setAddr(timespec)
            self._rawLength = 1
            self.configureTimeout(clock: clock, options: .absolute)
            self.data = data
        }

        @inlinable
        public mutating func poll(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            events: Linux.Kernel.Event.Poll.Events,
            multishot: Bool = false,
            trigger: ISO_9945.Kernel.IO.Uring.Poll.Trigger = .edge,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .poll.add
            target.apply(to: &self)
            self.pollEvents = events
            var options = trigger.option
            if multishot { options.insert(.multishot) }
            self.pollOptions = options
            self.data = data
        }

        @inlinable
        public mutating func poll(
            remove target: ISO_9945.Kernel.IO.Uring.Operation.Data,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .poll.remove
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            self.setAddr(target)
            self.data = data
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {

        @inlinable
        public mutating func message(
            ring fd: Int32,
            value: UInt32,
            targetData: ISO_9945.Kernel.IO.Uring.Operation.Data,
            flags: ISO_9945.Kernel.IO.Uring.Message.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .ring.msg
            self.messageRingFd = fd
            self.messageValue = value
            self.setMessageTarget(targetData)
            self.messageRingFlags = flags
            self.data = data
        }

        @inlinable @unsafe
        public mutating func provide(
            buffer: UnsafeRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            count: Int32,
            group: ISO_9945.Kernel.IO.Uring.Buffer.Group,
            startId: UInt16,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .buffer.provide
            self.bufferCount = count
            unsafe self.setAddr(buffer)
            self.len = length
            self.bufferStartID = startId
            self._bufferGroup = group
            self.data = data
        }

        @inlinable
        public mutating func remove(
            bufferCount count: Int32,
            group: ISO_9945.Kernel.IO.Uring.Buffer.Group,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .buffer.remove
            self.bufferCount = count
            self._bufferGroup = group
            self.data = data
        }

        @inlinable @unsafe
        public mutating func files(
            update fds: UnsafePointer<Int32>,
            count: UInt32,
            offset: UInt32,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.update
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            unsafe self.setAddr(fds)
            self._rawLength = count
            self._rawOffset = UInt64(offset)
            self.data = data
        }

        @inlinable
        public mutating func command(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            op: UInt32,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .ring.cmd
            target.apply(to: &self)
            self.commandOpcode = op
            self.data = data
        }

        @inlinable
        public mutating func install(
            fd: UInt32,
            flags: ISO_9945.Kernel.IO.Uring.Fixed.Install.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .fixed.install
            self._fd = Int32(bitPattern: fd)
            self.installFlags = flags
            self.data = data
        }

        @inlinable @unsafe
        public mutating func pipe(
            fds: UnsafeMutablePointer<Int32>,
            flags: ISO_9945.Kernel.Pipe.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .pipe.create
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            unsafe self.setAddr(fds)
            self.pipeCreateFlags = flags
            self.data = data
        }

        @inlinable
        public mutating func nop128(data: ISO_9945.Kernel.IO.Uring.Operation.Data) {
            self = .init()
            self.opcode = .nop128
            self.data = data
        }

        @inlinable @unsafe
        public mutating func waitid(
            kind: ISO_9945.Kernel.Process.Wait.Kind,
            id: ISO_9945.Kernel.Process.ID,
            info: UnsafeMutablePointer<ISO_9945.Kernel.Signal.Information>,
            options: ISO_9945.Kernel.Process.Wait.Options,
            flags: ISO_9945.Kernel.IO.Uring.Wait.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .wait.id
            self.setWaitidProcess(id)
            self.waitidKind = kind
            unsafe self.setOffset(info)
            self.waitidOptions = options
            self.waitidFlags = flags
            self.data = data
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {

        @inlinable
        public mutating func fadvise(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            length: ISO_9945.Kernel.IO.Uring.Length,
            advice: ISO_9945.Kernel.File.Advice,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.fadvise
            target.apply(to: &self)
            self.offset = offset
            self.len = length
            self.fileAdvice = advice
            self.data = data
        }

        @inlinable @unsafe
        public mutating func madvise(
            addr: UnsafeMutableRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            advice: Memory.Map.Advice,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .memory.madvise
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            unsafe self.setAddr(addr)
            self.len = length
            self.memoryAdvice = advice
            self.data = data
        }

        @inlinable
        public mutating func sync(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            length: ISO_9945.Kernel.IO.Uring.Length,
            flags: ISO_9945.Kernel.File.Sync.Range.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .sync.file.range
            target.apply(to: &self)
            self.offset = offset
            self.len = length
            self.syncRangeFlags = flags
            self.data = data
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {

        @inlinable @unsafe
        public mutating func futex(
            wait futex: UnsafePointer<UInt32>,
            value: UInt64,
            mask: UInt64,
            flags: ISO_9945.Kernel.Futex.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .futex.wait

            unsafe self.setAddr(futex)
            self.offset = ISO_9945.Kernel.IO.Uring.Offset(value)
            self.futexFlags = flags
            self._addr3 = mask
            self.data = data
        }

        @inlinable @unsafe
        public mutating func futex(
            wake futex: UnsafePointer<UInt32>,
            value: UInt64,
            mask: UInt64,
            flags: ISO_9945.Kernel.Futex.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .futex.wake

            unsafe self.setAddr(futex)
            self.offset = ISO_9945.Kernel.IO.Uring.Offset(value)
            self.futexFlags = flags
            self._addr3 = mask
            self.data = data
        }

        @inlinable @unsafe
        public mutating func futex(
            wait entries: UnsafePointer<ISO_9945.Kernel.Futex.Wait.Entry>,
            count: UInt32,
            flags: ISO_9945.Kernel.Futex.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .futex.waitv

            unsafe self.setAddr(entries)
            self._rawLength = count
            self.futexFlags = flags
            self.data = data
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {

        @inlinable @unsafe
        public mutating func fsetxattr(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            name: UnsafePointer<CChar>,
            value: UnsafeRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            disposition: ISO_9945.Kernel.IO.Uring.File.Xattr.Disposition = .createOrReplace,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .xattr.fset
            target.apply(to: &self)
            unsafe self.setAddr(name)
            self.len = length
            unsafe self.setOffset(value)
            self.setXattrDisposition(disposition)
            self.data = data
        }

        @inlinable @unsafe
        public mutating func setxattr(
            name: UnsafePointer<CChar>,
            value: UnsafeRawPointer,
            path: UnsafePointer<CChar>,
            length: ISO_9945.Kernel.IO.Uring.Length,
            disposition: ISO_9945.Kernel.IO.Uring.File.Xattr.Disposition = .createOrReplace,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .xattr.set

            unsafe self.setAddr(name)
            self.len = length
            unsafe self.setOffset(value)
            unsafe self.setAddr3(path)
            self.setXattrDisposition(disposition)
            self.data = data
        }

        @inlinable @unsafe
        public mutating func fgetxattr(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            name: UnsafePointer<CChar>,
            value: UnsafeMutableRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .xattr.fget
            target.apply(to: &self)
            unsafe self.setAddr(name)
            self.len = length
            unsafe self.setOffset(value)
            self.data = data
        }

        @inlinable @unsafe
        public mutating func getxattr(
            name: UnsafePointer<CChar>,
            value: UnsafeMutableRawPointer,
            path: UnsafePointer<CChar>,
            length: ISO_9945.Kernel.IO.Uring.Length,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .xattr.get

            unsafe self.setAddr(name)
            self.len = length
            unsafe self.setOffset(value)
            unsafe self.setAddr3(path)
            self.data = data
        }
    }

#endif
