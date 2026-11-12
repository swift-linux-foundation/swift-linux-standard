#ifndef CLINUX_SHIM_H
#define CLINUX_SHIM_H

#if defined(__linux__)

#include <sys/epoll.h>
#include <sys/eventfd.h>
#include <sys/statfs.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <stdint.h>

#include <fcntl.h>

#ifndef AT_EMPTY_PATH
#define AT_EMPTY_PATH 0x1000
#endif

#ifndef SYNC_FILE_RANGE_WAIT_BEFORE
#define SYNC_FILE_RANGE_WAIT_BEFORE 1
#endif
#ifndef SYNC_FILE_RANGE_WRITE
#define SYNC_FILE_RANGE_WRITE 2
#endif
#ifndef SYNC_FILE_RANGE_WAIT_AFTER
#define SYNC_FILE_RANGE_WAIT_AFTER 4
#endif

#ifndef FALLOC_FL_KEEP_SIZE
#define FALLOC_FL_KEEP_SIZE 0x01
#endif
#ifndef FALLOC_FL_PUNCH_HOLE
#define FALLOC_FL_PUNCH_HOLE 0x02
#endif
#ifndef FALLOC_FL_COLLAPSE_RANGE
#define FALLOC_FL_COLLAPSE_RANGE 0x08
#endif
#ifndef FALLOC_FL_ZERO_RANGE
#define FALLOC_FL_ZERO_RANGE 0x10
#endif
#ifndef FALLOC_FL_INSERT_RANGE
#define FALLOC_FL_INSERT_RANGE 0x20
#endif
#ifndef FALLOC_FL_UNSHARE_RANGE
#define FALLOC_FL_UNSHARE_RANGE 0x40
#endif

#include <sys/xattr.h>
#ifndef XATTR_CREATE
#define XATTR_CREATE 1
#endif
#ifndef XATTR_REPLACE
#define XATTR_REPLACE 2
#endif

#ifndef SPLICE_F_MOVE
#define SPLICE_F_MOVE 1
#endif
#ifndef SPLICE_F_NONBLOCK
#define SPLICE_F_NONBLOCK 2
#endif
#ifndef SPLICE_F_MORE
#define SPLICE_F_MORE 4
#endif

#ifndef O_DIRECT
#define O_DIRECT 040000
#endif

#ifndef FICLONE
#define FICLONE 0x40049409
#endif

#ifndef LINUX_IO_URING_H

struct io_uring_sqe {
    uint8_t opcode;
    uint8_t flags;
    uint16_t ioprio;
    int32_t fd;
    union {
        uint64_t off;
        uint64_t addr2;
        struct {
            uint32_t cmd_op;
            uint32_t __pad1;
        };
    };
    union {
        uint64_t addr;
        uint64_t splice_off_in;
        struct {
            uint32_t level;
            uint32_t optname;
        };
    };
    uint32_t len;
    union {
        uint32_t rw_flags;
        uint32_t fsync_flags;
        uint16_t poll_events;
        uint32_t poll32_events;
        uint32_t sync_range_flags;
        uint32_t msg_flags;
        uint32_t timeout_flags;
        uint32_t accept_flags;
        uint32_t cancel_flags;
        uint32_t open_flags;
        uint32_t statx_flags;
        uint32_t fadvise_advice;
        uint32_t splice_flags;
        uint32_t rename_flags;
        uint32_t unlink_flags;
        uint32_t hardlink_flags;
        uint32_t xattr_flags;
        uint32_t msg_ring_flags;
        uint32_t uring_cmd_flags;
        uint32_t waitid_flags;
        uint32_t futex_flags;
        uint32_t install_fd_flags;
    };
    uint64_t user_data;
    union {
        uint16_t buf_index;
        uint16_t buf_group;
    } __attribute__((packed));
    uint16_t personality;
    union {
        int32_t splice_fd_in;
        uint32_t file_index;
        uint32_t optlen;
        struct {
            uint16_t addr_len;
            uint16_t __pad3[1];
        };
    };
    union {
        struct {
            uint64_t addr3;
            uint64_t __pad2[1];
        };
        uint64_t optval;
    };
};

struct io_uring_cqe {
    uint64_t user_data;
    int32_t res;
    uint32_t flags;
    uint64_t big_cqe[];
};

struct io_sqring_offsets {
    uint32_t head;
    uint32_t tail;
    uint32_t ring_mask;
    uint32_t ring_entries;
    uint32_t flags;
    uint32_t dropped;
    uint32_t array;
    uint32_t resv1;
    uint64_t user_addr;
};

struct io_cqring_offsets {
    uint32_t head;
    uint32_t tail;
    uint32_t ring_mask;
    uint32_t ring_entries;
    uint32_t overflow;
    uint32_t cqes;
    uint32_t flags;
    uint32_t resv1;
    uint64_t user_addr;
};

struct io_uring_params {
    uint32_t sq_entries;
    uint32_t cq_entries;
    uint32_t flags;
    uint32_t sq_thread_cpu;
    uint32_t sq_thread_idle;
    uint32_t features;
    uint32_t wq_fd;
    uint32_t resv[3];
    struct io_sqring_offsets sq_off;
    struct io_cqring_offsets cq_off;
};

#define IORING_FSYNC_DATASYNC (1U << 0)
#define IORING_TIMEOUT_ABS (1U << 0)
#define IORING_TIMEOUT_UPDATE (1U << 1)
#define IORING_TIMEOUT_BOOTTIME (1U << 2)
#define IORING_TIMEOUT_REALTIME (1U << 3)
#define IORING_LINK_TIMEOUT_UPDATE (1U << 4)
#define IORING_POLL_ADD_MULTI (1U << 0)
#define IORING_POLL_UPDATE_EVENTS (1U << 1)
#define IORING_POLL_UPDATE_USER_DATA (1U << 2)

#endif

#ifndef _LINUX_OPENAT2_H

struct open_how {
    uint64_t flags;
    uint64_t mode;
    uint64_t resolve;
};

#define RESOLVE_NO_XDEV 0x01
#define RESOLVE_NO_MAGICLINKS 0x02
#define RESOLVE_NO_SYMLINKS 0x04
#define RESOLVE_BENEATH 0x08
#define RESOLVE_IN_ROOT 0x10
#define RESOLVE_CACHED 0x20

#endif

#ifndef STATX_TYPE

struct statx_timestamp {
    int64_t tv_sec;
    uint32_t tv_nsec;
    int32_t __reserved;
};

struct statx {
    uint32_t stx_mask;
    uint32_t stx_blksize;
    uint64_t stx_attributes;
    uint32_t stx_nlink;
    uint32_t stx_uid;
    uint32_t stx_gid;
    uint16_t stx_mode;
    uint16_t __spare0[1];
    uint64_t stx_ino;
    uint64_t stx_size;
    uint64_t stx_blocks;
    uint64_t stx_attributes_mask;
    struct statx_timestamp stx_atime;
    struct statx_timestamp stx_btime;
    struct statx_timestamp stx_ctime;
    struct statx_timestamp stx_mtime;
    uint32_t stx_rdev_major;
    uint32_t stx_rdev_minor;
    uint32_t stx_dev_major;
    uint32_t stx_dev_minor;
    uint64_t stx_mnt_id;
    uint32_t stx_dio_mem_align;
    uint32_t stx_dio_offset_align;
    uint64_t __spare3[12];
};

#define STATX_TYPE 0x00000001U
#define STATX_MODE 0x00000002U
#define STATX_NLINK 0x00000004U
#define STATX_UID 0x00000008U
#define STATX_GID 0x00000010U
#define STATX_ATIME 0x00000020U
#define STATX_MTIME 0x00000040U
#define STATX_CTIME 0x00000080U
#define STATX_INO 0x00000100U
#define STATX_SIZE 0x00000200U
#define STATX_BLOCKS 0x00000400U
#define STATX_BASIC_STATS 0x000007ffU
#define STATX_BTIME 0x00000800U

#endif

#ifndef STATX_MNT_ID
#define STATX_MNT_ID 0x00001000U
#endif
#ifndef STATX_ATTR_COMPRESSED
#define STATX_ATTR_COMPRESSED 0x00000004
#endif
#ifndef STATX_ATTR_IMMUTABLE
#define STATX_ATTR_IMMUTABLE 0x00000010
#endif
#ifndef STATX_ATTR_APPEND
#define STATX_ATTR_APPEND 0x00000020
#endif
#ifndef STATX_ATTR_NODUMP
#define STATX_ATTR_NODUMP 0x00000040
#endif
#ifndef STATX_ATTR_ENCRYPTED
#define STATX_ATTR_ENCRYPTED 0x00000800
#endif
#ifndef STATX_ATTR_VERITY
#define STATX_ATTR_VERITY 0x00100000
#endif
#ifndef STATX_ATTR_DAX
#define STATX_ATTR_DAX 0x00200000
#endif

enum { swift_statx_mnt_id_offset = 0x90 };

static inline uint32_t swift_io_uring_sqe_get_cmd_op(const struct io_uring_sqe *sqe) {
    return sqe->cmd_op;
}
static inline void swift_io_uring_sqe_set_cmd_op(struct io_uring_sqe *sqe, uint32_t value) {
    sqe->cmd_op = value;
}
static inline uint64_t swift_io_uring_sqe_get_addr3(const struct io_uring_sqe *sqe) {
    return sqe->addr3;
}
static inline void swift_io_uring_sqe_set_addr3(struct io_uring_sqe *sqe, uint64_t value) {
    sqe->addr3 = value;
}

static inline uint64_t swift_statx_get_mnt_id(const struct statx *stx) {
    uint64_t value;
    __builtin_memcpy(&value, (const unsigned char *)stx + swift_statx_mnt_id_offset, sizeof(value));
    return value;
}

extern long int syscall(long int __sysno, ...) __attribute__((__nothrow__, __leaf__));
extern int ioctl(int __fd, unsigned long int __request, ...) __attribute__((__nothrow__, __leaf__));

#include <stddef.h>
#include <sys/types.h>

static inline ssize_t swift_copy_file_range(
    int fd_in, off_t *off_in,
    int fd_out, off_t *off_out,
    size_t len, unsigned int flags
) {
    return syscall(SYS_copy_file_range, fd_in, off_in, fd_out, off_out, len, flags);
}

static inline int swift_ficlone(int dest_fd, int src_fd) {
    return ioctl(dest_fd, FICLONE, src_fd);
}

static inline int swift_io_uring_setup(unsigned int entries, struct io_uring_params *p) {
    return (int)syscall(SYS_io_uring_setup, entries, p);
}

static inline int swift_io_uring_enter(
    int fd, unsigned int to_submit, unsigned int min_complete,
    unsigned int flags, void *sig, size_t sigsz
) {
    return (int)syscall(SYS_io_uring_enter, fd, to_submit, min_complete, flags, sig, sigsz);
}

static inline int swift_io_uring_register(
    int fd, unsigned int opcode, void *arg, unsigned int nr_args
) {
    return (int)syscall(SYS_io_uring_register, fd, opcode, arg, nr_args);
}

static inline ssize_t swift_getrandom(void *buf, size_t buflen, unsigned int flags) {
    return syscall(SYS_getrandom, buf, buflen, flags);
}

#ifndef RENAME_NOREPLACE
#define RENAME_NOREPLACE (1 << 0)
#endif
#ifndef RENAME_EXCHANGE
#define RENAME_EXCHANGE (1 << 1)
#endif
#ifndef RENAME_WHITEOUT
#define RENAME_WHITEOUT (1 << 2)
#endif

static inline int swift_renameat2(
    int olddirfd, const char *oldpath,
    int newdirfd, const char *newpath,
    unsigned int flags
) {
    return (int)syscall(SYS_renameat2, olddirfd, oldpath, newdirfd, newpath, flags);
}

static inline int swift_dup3(int oldfd, int newfd, int flags) {
    return (int)syscall(SYS_dup3, oldfd, newfd, flags);
}

static inline int swift_pipe2(int pipefd[2], int flags) {
    return (int)syscall(SYS_pipe2, pipefd, flags);
}

static inline int swift_sched_setaffinity(int pid, size_t cpusetsize, const void *mask) {
    return (int)syscall(SYS_sched_setaffinity, pid, cpusetsize, mask);
}

static inline pid_t swift_gettid(void) {
    return (pid_t)syscall(SYS_gettid);
}

static inline int swift_pidfd_open(pid_t pid, unsigned int flags) {
    return (int)syscall(SYS_pidfd_open, pid, flags);
}

static inline int swift_pidfd_send_signal(int pidfd, int sig, void *info, unsigned int flags) {
    return (int)syscall(SYS_pidfd_send_signal, pidfd, sig, info, flags);
}

#include <sys/timerfd.h>
#include <sys/signalfd.h>

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#define _CLINUX_SHIM_DEFINED_GNU_SOURCE
#endif
#include <dlfcn.h>
#ifdef _CLINUX_SHIM_DEFINED_GNU_SOURCE
#undef _GNU_SOURCE
#undef _CLINUX_SHIM_DEFINED_GNU_SOURCE
#endif

static inline void *swift_RTLD_DEFAULT(void) {
#ifdef RTLD_DEFAULT
    return RTLD_DEFAULT;
#else
    return (void *)0;
#endif
}

static inline void *swift_RTLD_NEXT(void) {
#ifdef RTLD_NEXT
    return RTLD_NEXT;
#else
    return (void *)-1l;
#endif
}

#endif

#endif
