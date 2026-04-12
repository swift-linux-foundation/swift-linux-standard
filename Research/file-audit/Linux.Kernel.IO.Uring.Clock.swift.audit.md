# Audit: Linux.Kernel.IO.Uring.Clock.swift

CLEAN -- no findings.

Correct enum modeling of `CLOCK_MONOTONIC`/`CLOCK_BOOTTIME`/`CLOCK_REALTIME` via `IORING_TIMEOUT_BOOTTIME` and `IORING_TIMEOUT_REALTIME` kernel flags. Nest.Name correct. One type per file. Excellent table documentation. Uses kernel header constants directly.
