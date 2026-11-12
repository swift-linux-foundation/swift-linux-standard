#include "reference.h"

#if defined(__linux__)

#include <shim.h>

#include "entries.h"

#define MNT_ID_OFFSET { "offsetof(struct statx, stx_mnt_id)", (uint64_t)swift_statx_mnt_id_offset },

static const struct swift_linux_uapi_entry entries[] = { SWIFT_LINUX_UAPI_ENTRIES };

size_t swift_linux_uapi_declared_count(void) { return sizeof(entries) / sizeof(entries[0]); }
const struct swift_linux_uapi_entry *swift_linux_uapi_declared(void) { return entries; }

#else

size_t swift_linux_uapi_declared_count(void) { return 0; }
const struct swift_linux_uapi_entry *swift_linux_uapi_declared(void) { return NULL; }

#endif
