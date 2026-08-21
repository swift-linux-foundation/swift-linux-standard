#ifndef CLINUX_SHIM_H
#define CLINUX_SHIM_H

#if defined(__linux__)

#include "uuid_shim.h"

#include <sys/epoll.h>
#include <sys/eventfd.h>
#include <sys/statfs.h>
#include <linux/fs.h>
#include <linux/io_uring.h>
#include <linux/openat2.h>
#include <linux/stat.h>
#include <sys/syscall.h>

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

#include <linux/falloc.h>

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

#if defined(IORING_SETUP_SQE128)
static inline __u32 swift_io_uring_sqe_get_cmd_op(const struct io_uring_sqe *sqe) {
    return sqe->cmd_op;
}
static inline void swift_io_uring_sqe_set_cmd_op(struct io_uring_sqe *sqe, __u32 value) {
    sqe->cmd_op = value;
}
static inline __u64 swift_io_uring_sqe_get_addr3(const struct io_uring_sqe *sqe) {
    return sqe->addr3;
}
static inline void swift_io_uring_sqe_set_addr3(struct io_uring_sqe *sqe, __u64 value) {
    sqe->addr3 = value;
}
#else
static inline __u32 swift_io_uring_sqe_get_cmd_op(const struct io_uring_sqe *sqe) {
    __u32 value;
    __builtin_memcpy(&value, (const unsigned char *)sqe + 8, sizeof(value));
    return value;
}
static inline void swift_io_uring_sqe_set_cmd_op(struct io_uring_sqe *sqe, __u32 value) {
    __builtin_memcpy((unsigned char *)sqe + 8, &value, sizeof(value));
}
static inline __u64 swift_io_uring_sqe_get_addr3(const struct io_uring_sqe *sqe) {
    __u64 value;
    __builtin_memcpy(&value, (const unsigned char *)sqe + 48, sizeof(value));
    return value;
}
static inline void swift_io_uring_sqe_set_addr3(struct io_uring_sqe *sqe, __u64 value) {
    __builtin_memcpy((unsigned char *)sqe + 48, &value, sizeof(value));
}
#endif

#if defined(STATX_MNT_ID)
static inline __u64 swift_statx_get_mnt_id(const struct statx *stx) {
    return stx->stx_mnt_id;
}
#else
static inline __u64 swift_statx_get_mnt_id(const struct statx *stx) {
    __u64 value;
    __builtin_memcpy(&value, (const unsigned char *)stx + 0x90, sizeof(value));
    return value;
}
#endif

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
