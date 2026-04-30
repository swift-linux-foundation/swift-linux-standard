// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)
    import Testing

    import Error_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard

    /// Tests for Kernel.IO.Uring.Offset (typealias to Coordinate.X.Value).
    extension Kernel.IO.Uring {
        @Suite
        enum OffsetTest {
            // MARK: - Unit Tests

            @Suite struct Unit {
                @Test
                func `Offset type exists`() {
                    let _: Kernel.IO.Uring.Offset.Type = Kernel.IO.Uring.Offset.self
                }

                @Test
                func `Offset.zero constant`() {
                    let zero = Kernel.IO.Uring.Offset.zero
                    #expect(zero == 0)
                }

                @Test
                func `Offset.current constant`() {
                    let current = Kernel.IO.Uring.Offset.current
                    #expect(current.rawValue == UInt64.max)
                }

                @Test
                func `Offset from File.Offset`() {
                    let offset = Kernel.IO.Uring.Offset(Kernel.File.Offset(4096))
                    #expect(offset == 4096)
                }

                @Test
                func `current description`() {
                    let current = Kernel.IO.Uring.Offset.current
                    #expect(current.description == "current")
                }

                @Test
                func `zero description`() {
                    let zero = Kernel.IO.Uring.Offset.zero
                    #expect(zero.description == "0")
                }

                @Test
                func `numeric offset description`() {
                    let offset = Kernel.IO.Uring.Offset(Kernel.File.Offset(4096))
                    #expect(offset.description == "4096")
                }

                @Test
                func `Offset is Sendable`() {
                    let offset: any Sendable = Kernel.IO.Uring.Offset.zero
                    #expect(offset is Kernel.IO.Uring.Offset)
                }

                @Test
                func `Offset is Equatable`() {
                    let a = Kernel.IO.Uring.Offset(Kernel.File.Offset(100))
                    let b = Kernel.IO.Uring.Offset(Kernel.File.Offset(100))
                    let c = Kernel.IO.Uring.Offset(Kernel.File.Offset(200))
                    #expect(a == b)
                    #expect(a != c)
                }

                @Test
                func `Offset is Hashable`() {
                    var set = Set<Kernel.IO.Uring.Offset>()
                    set.insert(.zero)
                    set.insert(.current)
                    set.insert(Kernel.IO.Uring.Offset(Kernel.File.Offset(100)))
                    set.insert(.zero)  // duplicate
                    #expect(set.count == 3)
                }

                @Test
                func `Offset from positive File.Offset`() {
                    let fileOffset = Kernel.File.Offset(1000)
                    let offset = Kernel.IO.Uring.Offset(fileOffset)
                    #expect(offset == 1000)
                }

                @Test
                func `Offset from zero File.Offset`() {
                    let fileOffset = Kernel.File.Offset(0)
                    let offset = Kernel.IO.Uring.Offset(fileOffset)
                    #expect(offset == 0)
                }

                @Test
                func `Offset from negative File.Offset becomes current`() {
                    let fileOffset = Kernel.File.Offset(-1)
                    let offset = Kernel.IO.Uring.Offset(fileOffset)
                    #expect(offset == .current)
                }
            }

            // MARK: - Edge Cases

            @Suite struct EdgeCase {
                @Test
                func `zero and current are distinct`() {
                    #expect(Kernel.IO.Uring.Offset.zero != Kernel.IO.Uring.Offset.current)
                }

                @Test
                func `max UInt64 value equals current`() {
                    let max = Kernel.IO.Uring.Offset(UInt64.max)
                    #expect(max == .current)
                }
            }
        }
    }
#endif
