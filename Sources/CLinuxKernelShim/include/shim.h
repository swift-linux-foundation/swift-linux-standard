#ifndef CLINUX_SHIM_H
#define CLINUX_SHIM_H

#if defined(__linux__)

#include "uuid_shim.h"

// NOTE: Do NOT define _GNU_SOURCE here - let Glibc handle it
// NOTE: Do NOT include <unistd.h> or <sys/ioctl.h> - already in SwiftGlibc
//       Including them here causes fd_set type conflicts.

// ONLY headers NOT in SwiftGlibc:
#include <sys/epoll.h>       // epoll - NOT in SwiftGlibc
#include <sys/eventfd.h>     // eventfd - NOT in SwiftGlibc
#include <sys/statfs.h>      // statfs - NOT in SwiftGlibc
#include <linux/fs.h>        // FICLONE macro
#include <linux/io_uring.h>  // io_uring structs
#include <sys/syscall.h>     // __NR_* syscall numbers (safe - just defines)

// Linux-specific constants not in SwiftGlibc
#include <fcntl.h>

// AT_EMPTY_PATH - Linux 2.6.39+
#ifndef AT_EMPTY_PATH
#define AT_EMPTY_PATH 0x1000
#endif

// sync_file_range flags - Linux 2.6.17+
#ifndef SYNC_FILE_RANGE_WAIT_BEFORE
#define SYNC_FILE_RANGE_WAIT_BEFORE 1
#endif
#ifndef SYNC_FILE_RANGE_WRITE
#define SYNC_FILE_RANGE_WRITE 2
#endif
#ifndef SYNC_FILE_RANGE_WAIT_AFTER
#define SYNC_FILE_RANGE_WAIT_AFTER 4
#endif

// xattr flags - from <sys/xattr.h>, not in SwiftGlibc
#include <sys/xattr.h>
#ifndef XATTR_CREATE
#define XATTR_CREATE 1
#endif
#ifndef XATTR_REPLACE
#define XATTR_REPLACE 2
#endif

// splice flags - not in SwiftGlibc
#ifndef SPLICE_F_MOVE
#define SPLICE_F_MOVE 1
#endif
#ifndef SPLICE_F_NONBLOCK
#define SPLICE_F_NONBLOCK 2
#endif
#ifndef SPLICE_F_MORE
#define SPLICE_F_MORE 4
#endif

// O_DIRECT - not in SwiftGlibc's fcntl overlay
#ifndef O_DIRECT
#define O_DIRECT 040000
#endif

// FICLONE - ioctl code for reflink cloning
// Value: _IOW(0x94, 9, int) = 0x40049409
#ifndef FICLONE
#define FICLONE 0x40049409
#endif

// Forward declarations of syscall/ioctl - already in glibc, just need signatures.
// These avoid including <unistd.h> and <sys/ioctl.h> which cause fd_set conflicts.
extern long int syscall(long int __sysno, ...) __attribute__((__nothrow__, __leaf__));
extern int ioctl(int __fd, unsigned long int __request, ...) __attribute__((__nothrow__, __leaf__));

// Syscall wrappers - non-variadic functions that Swift can call
// Types match Swift's expectations: off_t = long (Int), size_t = unsigned long (UInt)

#include <stddef.h>      // for size_t
#include <sys/types.h>   // for off_t, ssize_t

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

// getrandom - cryptographically secure random bytes from kernel CSPRNG
// Flags: GRND_NONBLOCK (1), GRND_RANDOM (2)
static inline ssize_t swift_getrandom(void *buf, size_t buflen, unsigned int flags) {
    return syscall(SYS_getrandom, buf, buflen, flags);
}

// renameat2 - atomic rename with flags
// Flags: RENAME_NOREPLACE (1), RENAME_EXCHANGE (2), RENAME_WHITEOUT (4)
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

// dup3 - duplicate fd with flags (close-on-exec)
// Linux extension (not POSIX), not in SwiftGlibc
static inline int swift_dup3(int oldfd, int newfd, int flags) {
    return (int)syscall(SYS_dup3, oldfd, newfd, flags);
}

// pipe2 - create pipe with flags (close-on-exec, non-blocking)
// Linux extension (not POSIX), not in SwiftGlibc
static inline int swift_pipe2(int pipefd[2], int flags) {
    return (int)syscall(SYS_pipe2, pipefd, flags);
}

// sched_setaffinity - set thread CPU affinity mask
// GNU extension, not in SwiftGlibc
static inline int swift_sched_setaffinity(int pid, size_t cpusetsize, const void *mask) {
    return (int)syscall(SYS_sched_setaffinity, pid, cpusetsize, mask);
}

#endif /* __linux__ */

#endif /* CLINUX_SHIM_H */
