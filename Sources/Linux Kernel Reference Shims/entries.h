#define SWIFT_LINUX_UAPI_ENTRIES \
    SIZE(struct io_uring_sqe) \
    OFFSET(struct io_uring_sqe, opcode) \
    OFFSET(struct io_uring_sqe, flags) \
    OFFSET(struct io_uring_sqe, ioprio) \
    OFFSET(struct io_uring_sqe, fd) \
    OFFSET(struct io_uring_sqe, off) \
    OFFSET(struct io_uring_sqe, addr2) \
    OFFSET(struct io_uring_sqe, cmd_op) \
    OFFSET(struct io_uring_sqe, addr) \
    OFFSET(struct io_uring_sqe, splice_off_in) \
    OFFSET(struct io_uring_sqe, len) \
    OFFSET(struct io_uring_sqe, rw_flags) \
    OFFSET(struct io_uring_sqe, poll32_events) \
    OFFSET(struct io_uring_sqe, user_data) \
    OFFSET(struct io_uring_sqe, buf_index) \
    OFFSET(struct io_uring_sqe, buf_group) \
    OFFSET(struct io_uring_sqe, personality) \
    OFFSET(struct io_uring_sqe, splice_fd_in) \
    OFFSET(struct io_uring_sqe, file_index) \
    OFFSET(struct io_uring_sqe, addr3) \
    SIZE(struct io_uring_cqe) \
    OFFSET(struct io_uring_cqe, user_data) \
    OFFSET(struct io_uring_cqe, res) \
    OFFSET(struct io_uring_cqe, flags) \
    SIZE(struct io_sqring_offsets) \
    OFFSET(struct io_sqring_offsets, head) \
    OFFSET(struct io_sqring_offsets, tail) \
    OFFSET(struct io_sqring_offsets, ring_mask) \
    OFFSET(struct io_sqring_offsets, ring_entries) \
    OFFSET(struct io_sqring_offsets, flags) \
    OFFSET(struct io_sqring_offsets, dropped) \
    OFFSET(struct io_sqring_offsets, array) \
    OFFSET(struct io_sqring_offsets, user_addr) \
    SIZE(struct io_cqring_offsets) \
    OFFSET(struct io_cqring_offsets, head) \
    OFFSET(struct io_cqring_offsets, tail) \
    OFFSET(struct io_cqring_offsets, ring_mask) \
    OFFSET(struct io_cqring_offsets, ring_entries) \
    OFFSET(struct io_cqring_offsets, overflow) \
    OFFSET(struct io_cqring_offsets, cqes) \
    OFFSET(struct io_cqring_offsets, flags) \
    OFFSET(struct io_cqring_offsets, user_addr) \
    SIZE(struct io_uring_params) \
    OFFSET(struct io_uring_params, sq_entries) \
    OFFSET(struct io_uring_params, cq_entries) \
    OFFSET(struct io_uring_params, flags) \
    OFFSET(struct io_uring_params, sq_thread_cpu) \
    OFFSET(struct io_uring_params, sq_thread_idle) \
    OFFSET(struct io_uring_params, features) \
    OFFSET(struct io_uring_params, wq_fd) \
    OFFSET(struct io_uring_params, sq_off) \
    OFFSET(struct io_uring_params, cq_off) \
    SIZE(struct open_how) \
    OFFSET(struct open_how, flags) \
    OFFSET(struct open_how, mode) \
    OFFSET(struct open_how, resolve) \
    SIZE(struct statx_timestamp) \
    OFFSET(struct statx_timestamp, tv_sec) \
    OFFSET(struct statx_timestamp, tv_nsec) \
    SIZE(struct statx) \
    OFFSET(struct statx, stx_mask) \
    OFFSET(struct statx, stx_blksize) \
    OFFSET(struct statx, stx_attributes) \
    OFFSET(struct statx, stx_nlink) \
    OFFSET(struct statx, stx_uid) \
    OFFSET(struct statx, stx_gid) \
    OFFSET(struct statx, stx_mode) \
    OFFSET(struct statx, stx_ino) \
    OFFSET(struct statx, stx_size) \
    OFFSET(struct statx, stx_blocks) \
    OFFSET(struct statx, stx_attributes_mask) \
    OFFSET(struct statx, stx_atime) \
    OFFSET(struct statx, stx_btime) \
    OFFSET(struct statx, stx_ctime) \
    OFFSET(struct statx, stx_mtime) \
    OFFSET(struct statx, stx_rdev_major) \
    OFFSET(struct statx, stx_rdev_minor) \
    OFFSET(struct statx, stx_dev_major) \
    OFFSET(struct statx, stx_dev_minor) \
    MNT_ID_OFFSET \
    CONSTANT(IORING_FSYNC_DATASYNC) \
    CONSTANT(IORING_TIMEOUT_ABS) \
    CONSTANT(IORING_TIMEOUT_UPDATE) \
    CONSTANT(IORING_TIMEOUT_BOOTTIME) \
    CONSTANT(IORING_TIMEOUT_REALTIME) \
    CONSTANT(IORING_LINK_TIMEOUT_UPDATE) \
    CONSTANT(IORING_POLL_ADD_MULTI) \
    CONSTANT(IORING_POLL_UPDATE_EVENTS) \
    CONSTANT(IORING_POLL_UPDATE_USER_DATA) \
    CONSTANT(RESOLVE_NO_XDEV) \
    CONSTANT(RESOLVE_NO_MAGICLINKS) \
    CONSTANT(RESOLVE_NO_SYMLINKS) \
    CONSTANT(RESOLVE_BENEATH) \
    CONSTANT(RESOLVE_IN_ROOT) \
    CONSTANT(RESOLVE_CACHED) \
    CONSTANT(STATX_TYPE) \
    CONSTANT(STATX_MODE) \
    CONSTANT(STATX_NLINK) \
    CONSTANT(STATX_UID) \
    CONSTANT(STATX_GID) \
    CONSTANT(STATX_ATIME) \
    CONSTANT(STATX_MTIME) \
    CONSTANT(STATX_CTIME) \
    CONSTANT(STATX_INO) \
    CONSTANT(STATX_SIZE) \
    CONSTANT(STATX_BLOCKS) \
    CONSTANT(STATX_BASIC_STATS) \
    CONSTANT(STATX_BTIME) \
    CONSTANT(STATX_MNT_ID) \
    CONSTANT(STATX_ATTR_COMPRESSED) \
    CONSTANT(STATX_ATTR_IMMUTABLE) \
    CONSTANT(STATX_ATTR_APPEND) \
    CONSTANT(STATX_ATTR_NODUMP) \
    CONSTANT(STATX_ATTR_ENCRYPTED) \
    CONSTANT(STATX_ATTR_VERITY) \
    CONSTANT(STATX_ATTR_DAX) \
    CONSTANT(FALLOC_FL_KEEP_SIZE) \
    CONSTANT(FALLOC_FL_PUNCH_HOLE) \
    CONSTANT(FALLOC_FL_COLLAPSE_RANGE) \
    CONSTANT(FALLOC_FL_ZERO_RANGE) \
    CONSTANT(FALLOC_FL_INSERT_RANGE) \
    CONSTANT(FALLOC_FL_UNSHARE_RANGE) \
    CONSTANT(FICLONE) \
    CONSTANT(RENAME_NOREPLACE) \
    CONSTANT(RENAME_EXCHANGE) \
    CONSTANT(RENAME_WHITEOUT)

#define SIZE(type) { "sizeof(" #type ")", (uint64_t)sizeof(type) },
#define OFFSET(type, field) { "offsetof(" #type ", " #field ")", (uint64_t)offsetof(type, field) },
#define CONSTANT(name) { #name, (uint64_t)(name) },
