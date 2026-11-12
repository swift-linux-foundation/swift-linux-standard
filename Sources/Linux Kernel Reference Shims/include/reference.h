#ifndef LINUX_KERNEL_REFERENCE_SHIMS_H
#define LINUX_KERNEL_REFERENCE_SHIMS_H

#include <stddef.h>
#include <stdint.h>

struct swift_linux_uapi_entry {
    const char *name;
    uint64_t value;
};

size_t swift_linux_uapi_kernel_count(void);
const struct swift_linux_uapi_entry *swift_linux_uapi_kernel(void);

size_t swift_linux_uapi_declared_count(void);
const struct swift_linux_uapi_entry *swift_linux_uapi_declared(void);

#endif
