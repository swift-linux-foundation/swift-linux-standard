#include "reference.h"

#if defined(__linux__) && __has_include(<linux/io_uring.h>)

#include <linux/fs.h>
#include <linux/io_uring.h>
#include <linux/openat2.h>
#include <linux/stat.h>
#include <linux/falloc.h>

#include "entries.h"

#define MNT_ID_OFFSET { "offsetof(struct statx, stx_mnt_id)", (uint64_t)offsetof(struct statx, stx_mnt_id) },

static const struct swift_linux_uapi_entry entries[] = { SWIFT_LINUX_UAPI_ENTRIES };

size_t swift_linux_uapi_kernel_count(void) { return sizeof(entries) / sizeof(entries[0]); }
const struct swift_linux_uapi_entry *swift_linux_uapi_kernel(void) { return entries; }

#else

size_t swift_linux_uapi_kernel_count(void) { return 0; }
const struct swift_linux_uapi_entry *swift_linux_uapi_kernel(void) { return NULL; }

#endif
