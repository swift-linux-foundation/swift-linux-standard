#define _GNU_SOURCE
#include "include/allocation_tracking.h"
#include <dlfcn.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>

static __thread int tracking_enabled = 0;
static __thread AllocationStats stats = {0};

static void* (*real_malloc)(size_t) = NULL;
static void (*real_free)(void*) = NULL;
static pthread_once_t init_once = PTHREAD_ONCE_INIT;

static void init_hooks(void) {
    real_malloc = dlsym(RTLD_NEXT, "malloc");
    real_free = dlsym(RTLD_NEXT, "free");
}

void* malloc(size_t size) {
    pthread_once(&init_once, init_hooks);

    void* ptr = real_malloc(size);

    if (tracking_enabled && ptr != NULL) {
        stats.allocations++;
        stats.bytes_allocated += size;
    }

    return ptr;
}

void free(void* ptr) {
    pthread_once(&init_once, init_hooks);

    if (tracking_enabled && ptr != NULL) {
        stats.deallocations++;
    }

    real_free(ptr);
}

void tracking_start(void) {
    memset(&stats, 0, sizeof(stats));
    tracking_enabled = 1;
}

AllocationStats tracking_stop(void) {
    tracking_enabled = 0;
    return stats;
}

AllocationStats tracking_current(void) {
    return stats;
}

void tracking_reset(void) {
    memset(&stats, 0, sizeof(stats));
}
