# swift-linux-standard

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Typed Swift bindings for Linux kernel system-call families, organized per subsystem — files, sockets, memory, timers, futexes, io_uring, and more.

The package is modular — import the specific `Linux … Standard` product your target needs; `Linux Kernel File Standard` is shown below as an example.

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/swift-linux-foundation/swift-linux-standard.git", branch: "main")
]
```

Add the product to a target that needs it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Linux Kernel File Standard", package: "swift-linux-standard")
    ]
)
```

On Linux, the kernel shims include `<uuid/uuid.h>`, so building requires the libuuid development headers: install `uuid-dev` on Debian and Ubuntu, or `libuuid-devel` on Fedora and RHEL.

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
