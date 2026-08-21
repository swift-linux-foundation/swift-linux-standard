#ifndef ALLOCATION_TRACKING_H
#define ALLOCATION_TRACKING_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    uint64_t allocations;
    uint64_t deallocations;
    uint64_t bytes_allocated;
} AllocationStats;

void tracking_start(void);

AllocationStats tracking_stop(void);

AllocationStats tracking_current(void);

void tracking_reset(void);

#ifdef __cplusplus
}
#endif

#endif
