//
//  RingBuffer.swift
//  Optimization
//
//  Created by Vaida on 2025-05-09.
//

import Testing
@testable
import Optimization


final class RBTestObject: Equatable, CustomStringConvertible {
    let id: Int
    var score: Double

    init(id: Int, score: Double = 0) {
        self.id = id
        self.score = score
    }

    static func == (lhs: RBTestObject, rhs: RBTestObject) -> Bool { lhs.id == rhs.id && lhs.score == rhs.score }
    var description: String { "Obj(\(id))" }
}


private enum TestError: Error, Equatable {
    case intentional
}


// MARK: - Basic Properties

@Suite
struct RingBufferBasicTests {

    @Test
    func empty() {
        let ring = RingBuffer<Int>()
        #expect(ring.isEmpty)
        #expect(ring.count == 0)
        #expect(ring.first == nil)
        #expect(ring.last == nil)
    }

    @Test
    func capacityIsPowerOfTwo() {
        let ring = RingBuffer<Int>(minimumCapacity: 3)
        #expect(ring.capacity == 4)
        #expect(ring.capacity & (ring.capacity - 1) == 0) // power-of-two check

        let ring2 = RingBuffer<Int>(minimumCapacity: 100)
        #expect(ring2.capacity == 128)
    }

    @Test
    func defaultMinimumCapacity() {
        let ring = RingBuffer<Int>()
        #expect(ring.capacity >= 1)
        #expect(ring.capacity & (ring.capacity - 1) == 0)
    }

    @Test
    func minimumCapacityZero() {
        let ring = RingBuffer<Int>(minimumCapacity: 0)
        #expect(ring.capacity == 1) // nextPowerOfTwo(0) = 1
        #expect(ring.isEmpty)
    }

    @Test
    func minimumCapacityOne() {
        let ring = RingBuffer<Int>(minimumCapacity: 1)
        #expect(ring.capacity == 1)
    }

    @Test
    func count() {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        #expect(ring.count == 0)

        ring.append(1)
        #expect(ring.count == 1)

        ring.append(2)
        #expect(ring.count == 2)

        _ = ring.removeFirst()
        #expect(ring.count == 1)

        _ = ring.removeLast()
        #expect(ring.count == 0)
    }

    @Test
    func isEmptyTracking() {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        #expect(ring.isEmpty)

        ring.append(1)
        #expect(!ring.isEmpty)

        _ = ring.removeFirst()
        #expect(ring.isEmpty)
    }

    @Test
    func isFullTracking() {
        let ring = RingBuffer<Int>(minimumCapacity: 2)
        #expect(!ring.isFull)

        ring.append(1)
        #expect(!ring.isFull)

        ring.append(2)
        #expect(ring.isFull)

        _ = ring.removeFirst()
        #expect(!ring.isFull)
    }

    @Test
    func firstAndLast() {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        #expect(ring.first == nil)
        #expect(ring.last == nil)

        ring.append(10)
        #expect(ring.first == 10)
        #expect(ring.last == 10)

        ring.append(20)
        #expect(ring.first == 10)
        #expect(ring.last == 20)
    }

}


// MARK: - Append / Prepend

@Suite
struct RingBufferAppendPrependTests {

    @Test
    func append() {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        ring.append(10)
        ring.append(20)
        ring.append(30)
        #expect(!ring.isEmpty)
        #expect(ring.count == 3)
        #expect(ring.first == 10)
        #expect(ring.last  == 30)
    }

    @Test
    func prepend() {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        ring.prepend(1)
        #expect(ring.first == 1)
        #expect(ring.last == 1)

        ring.prepend(0)
        #expect(ring.first == 0)
        #expect(ring.last == 1)

        ring.append(2)
        #expect(ring.first == 0)
        #expect(ring.last == 2)
    }

    @Test
    func interleavedPrependAppend() {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        ring.prepend(1)
        ring.append(2)
        // [1, 2]
        ring.prepend(0)
        // [0, 1, 2]
        #expect(ring.first == 0)
        #expect(ring.last == 2)
        #expect(ring.removeFirst() == 0)
        #expect(ring.removeLast() == 2)
        #expect(ring.removeFirst() == 1)
        #expect(ring.isEmpty)
    }

    @Test
    func appendTriggersGrow() {
        let ring = RingBuffer<Int>(minimumCapacity: 2)
        ring.append(1)
        ring.append(2)  // full
        #expect(ring.isFull)

        ring.append(3)  // triggers grow
        #expect(ring.capacity == 4)
        #expect(ring.count == 3)
        #expect(ring.first == 1)
        #expect(ring.last == 3)
    }

    @Test
    func prependTriggersGrow() {
        let ring = RingBuffer<Int>(minimumCapacity: 2)
        ring.append(1)
        ring.append(2)  // full
        #expect(ring.isFull)

        ring.prepend(0)  // triggers grow
        #expect(ring.capacity == 4)
        #expect(ring.count == 3)
        #expect(ring.first == 0)
        #expect(ring.last == 2)
    }

}


// MARK: - Remove

@Suite
struct RingBufferRemoveTests {

    @Test
    func appendAndRemoveFirst() {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        ring.append(10)
        ring.append(20)
        ring.append(30)
        #expect(!ring.isEmpty)
        #expect(ring.count == 3)
        #expect(ring.first == 10)
        #expect(ring.last  == 30)

        let a = ring.removeFirst()
        #expect(a == 10)
        #expect(ring.count == 2)
        #expect(ring.first == 20)

        let b = ring.removeFirst()
        #expect(b == 20)
        #expect(ring.count == 1)
        #expect(ring.first == 30)

        let c = ring.removeFirst()
        #expect(c == 30)
        #expect(ring.isEmpty)
        #expect(ring.first == nil)
    }

    @Test
    func appendAndRemoveLast() {
        let ring = RingBuffer<String>(minimumCapacity: 2)
        ring.append("A")
        ring.append("B")
        ring.append("C")   // triggers grow
        #expect(ring.count == 3)
        #expect(ring.first == "A")
        #expect(ring.last  == "C")

        let x = ring.removeLast()
        #expect(x == "C")
        #expect(ring.count == 2)
        #expect(ring.last  == "B")

        _ = ring.removeLast()
        let z = ring.removeLast()
        #expect(z == "A")
        #expect(ring.isEmpty)
    }

    @Test
    func removeFirstFromEmpty() {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        #expect(ring.removeFirst() == nil)
    }

    @Test
    func removeLastFromEmpty() {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        #expect(ring.removeLast() == nil)
    }

    @Test
    func removeAllThenAppend() {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        ring.append(1)
        ring.append(2)
        ring.append(3)
        _ = ring.removeFirst()
        _ = ring.removeFirst()
        _ = ring.removeFirst()
        #expect(ring.isEmpty)

        ring.append(10)
        #expect(ring.count == 1)
        #expect(ring.first == 10)
    }

    @Test
    func removeLastThenAppend() {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        ring.append(1)
        ring.append(2)
        ring.append(3)
        // [1, 2, 3]
        #expect(ring.removeLast() == 3)
        // [1, 2]
        ring.append(4)
        // [1, 2, 4]
        #expect(ring.last == 4)
        #expect(ring.removeFirst() == 1)
        #expect(ring.removeFirst() == 2)
        #expect(ring.removeFirst() == 4)
        #expect(ring.isEmpty)
    }

    @Test
    func removeFirstPreservesOrder() {
        let ring = RingBuffer<Int>(minimumCapacity: 8)
        for i in 0..<100 {
            ring.append(i)
            _ = ring.removeFirst()
        }
        // buffer should still be functional
        ring.append(42)
        #expect(ring.first == 42)
        #expect(ring.count == 1)
    }

}


// MARK: - Wrap-Around

@Suite
struct RingBufferWrapAroundTests {

    @Test
    func appendWrapAround() {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        // append four elements
        for i in 0..<4 { ring.append(i) }    // [0,1,2,3]
        // remove two from front -> head moves to 2
        _ = ring.removeFirst()               // drops 0
        _ = ring.removeFirst()               // drops 1
        #expect(ring.count == 2)
        #expect(ring.first == 2)
        #expect(ring.last  == 3)
        // now append two more to force wrap
        ring.append(4)
        ring.append(5)
        #expect(ring.count == 4)
        // logical content must be [2,3,4,5]
        var seen: [Int] = []
        ring.forEach { seen.append($0) }
        #expect(seen == [2,3,4,5])
    }

    @Test
    func prependWrapAround() {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        // fill completely
        ring.append(0)
        ring.append(1)
        ring.append(2)
        ring.append(3)
        // [0, 1, 2, 3], head=0, tail=3, full
        #expect(ring.isFull)

        // remove first two
        ring.removeFirst() // drops 0, head=1
        ring.removeFirst() // drops 1, head=2
        // [2, 3]

        // prepend two more — wraps head backward
        ring.prepend(10)
        ring.prepend(20)
        // [20, 10, 2, 3]

        var seen: [Int] = []
        ring.forEach { seen.append($0) }
        #expect(seen == [20, 10, 2, 3])
    }

    @Test
    func wrapAroundMultipleTimes() {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        for i in 0..<1000 {
            ring.append(i)
            _ = ring.removeFirst()
        }
        #expect(ring.isEmpty)

        ring.append(1)
        ring.append(2)
        ring.append(3)
        var seen: [Int] = []
        ring.forEach { seen.append($0) }
        #expect(seen == [1, 2, 3])
    }

}


// MARK: - Grow

@Suite
struct RingBufferGrowTests {

    @Test
    func growCapacityDoubling() {
        let ring = RingBuffer<Int>(minimumCapacity: 3)
        let initialCap = ring.capacity
        // fill to capacity
        for i in 0..<initialCap { ring.append(i) }
        #expect(ring.isFull)
        // next append must double
        ring.append(99)
        #expect(ring.capacity == initialCap * 2)
        #expect(ring.count == initialCap + 1)
        // verify contents in order
        var arr: [Int] = []
        ring.forEach { arr.append($0) }
        let expected = Array(0..<initialCap) + [99]
        #expect(arr == expected)
    }

    @Test
    func growFromWrapAround() {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        for i in 0..<4 { ring.append(i) }
        ring.removeFirst()
        ring.removeFirst()
        // [2, 3], head=2
        ring.append(4)
        ring.append(5)
        // [2, 3, 4, 5] full, head at 2
        #expect(ring.isFull)

        ring.append(6) // triggers grow
        #expect(ring.capacity == 8)
        #expect(ring.count == 5)
        var seen: [Int] = []
        ring.forEach { seen.append($0) }
        #expect(seen == [2, 3, 4, 5, 6])
    }

    @Test
    func growPreservesHeadAndTail() {
        let ring = RingBuffer<Int>(minimumCapacity: 2)
        ring.append(1)       // [1]
        _ = ring.removeFirst() // empty
        ring.append(2)       // [2]
        ring.append(3)       // [2, 3]
        ring.append(4)       // triggers grow: [2, 3, 4]
        #expect(ring.count == 3)
        #expect(ring.first == 2)
        #expect(ring.last == 4)
    }

    @Test
    func growFromEmpty() {
        // grow is never called on empty, but full→grow with 1 element works
        let ring = RingBuffer<Int>(minimumCapacity: 1)
        ring.append(1)
        #expect(ring.isFull)
        ring.append(2) // triggers grow
        #expect(ring.capacity == 2)
        #expect(ring.count == 2)
    }

}


// MARK: - nextPowerOfTwo (internal)

@Suite
struct RingBufferNextPowerOfTwoTests {

    @Test
    func nextPowerOfTwo() {
        #expect(RingBuffer<Int>.nextPowerOfTwo(0) == 1)
        #expect(RingBuffer<Int>.nextPowerOfTwo(1) == 1)
        #expect(RingBuffer<Int>.nextPowerOfTwo(2) == 2)
        #expect(RingBuffer<Int>.nextPowerOfTwo(3) == 4)
        #expect(RingBuffer<Int>.nextPowerOfTwo(4) == 4)
        #expect(RingBuffer<Int>.nextPowerOfTwo(5) == 8)
        #expect(RingBuffer<Int>.nextPowerOfTwo(7) == 8)
        #expect(RingBuffer<Int>.nextPowerOfTwo(8) == 8)
        #expect(RingBuffer<Int>.nextPowerOfTwo(9) == 16)
        #expect(RingBuffer<Int>.nextPowerOfTwo(100) == 128)
        #expect(RingBuffer<Int>.nextPowerOfTwo(1000) == 1024)
    }

}


// MARK: - Initializers

@Suite
struct RingBufferInitializerTests {

    @Test
    func collectionInit() {
        let ring = RingBuffer([1, 2, 3, 4, 5])
        #expect(ring.count == 5)
        #expect(ring.first == 1)
        #expect(ring.last == 5)

        var seen: [Int] = []
        ring.forEach { seen.append($0) }
        #expect(seen == [1, 2, 3, 4, 5])
    }

    @Test
    func collectionInitEmpty() {
        let ring = RingBuffer(EmptyCollection<Int>())
        #expect(ring.isEmpty)
        #expect(ring.count == 0)
    }

    @Test
    func collectionInitSingle() {
        let ring = RingBuffer([42])
        #expect(ring.count == 1)
        #expect(ring.first == 42)
        #expect(ring.last == 42)
    }

    @Test
    func arrayLiteralInit() {
        let ring: RingBuffer = [10, 20, 30]
        #expect(ring.count == 3)
        #expect(ring.first == 10)
        #expect(ring.last == 30)
    }

    @Test
    func arrayLiteralEmpty() {
        let ring: RingBuffer<Int> = []
        #expect(ring.isEmpty)
    }

    @Test
    func arrayFromRing() {
        let ring: RingBuffer = [1, 2, 3, 4, 5]
        let array = Array(ring)
        #expect(array == [1, 2, 3, 4, 5])
        // original preserved (borrowing)
        #expect(ring.count == 5)
    }

    @Test
    func arrayFromEmptyRing() {
        let ring = RingBuffer<Int>()
        #expect(Array(ring) == [])
    }

}


// MARK: - forEach

@Suite
struct RingBufferForEachTests {

    @Test
    func forEachFIFO() {
        let ring: RingBuffer = [10, 20, 30]
        var seen: [Int] = []
        ring.forEach { seen.append($0) }
        #expect(seen == [10, 20, 30])
        #expect(ring.count == 3) // forEach must not mutate
    }

    @Test
    func forEachEmpty() throws {
        let ring = RingBuffer<Int>()
        var called = false
        ring.forEach { _ in called = true }
        #expect(!called)
    }

    @Test
    func forEachSingle() throws {
        let ring: RingBuffer = [42]
        var seen: [Int] = []
        ring.forEach { seen.append($0) }
        #expect(seen == [42])
    }

    @Test
    func forEachThrows() throws {
        let ring: RingBuffer = [1, 2, 3, 4, 5]
        var visited: [Int] = []

        #expect(throws: TestError.intentional) {
            try ring.forEach { value in
                visited.append(value)
                if value == 3 {
                    throw TestError.intentional
                }
            }
        }
        #expect(visited == [1, 2, 3])
        #expect(ring.count == 5)
    }

    @Test
    func forEachAfterWrapAround() throws {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        for i in 0..<4 { ring.append(i) }
        ring.removeFirst()
        ring.removeFirst()
        ring.append(4)
        ring.append(5)
        // [2, 3, 4, 5]

        var seen: [Int] = []
        ring.forEach { seen.append($0) }
        #expect(seen == [2, 3, 4, 5])
    }

}


// MARK: - IteratorProtocol

@Suite
struct RingBufferIteratorTests {

    @Test
    func nextConsumesFromFront() {
        let ring: RingBuffer = [1, 2, 3]
        var collected: [Int] = []
        while let v = ring.next() {
            collected.append(v)
        }
        // next() is alias for removeFirst()
        #expect(collected == [1, 2, 3])
        #expect(ring.isEmpty)
    }

    @Test
    func nextOnEmpty() {
        let ring = RingBuffer<Int>()
        #expect(ring.next() == nil)
    }

    @Test
    func nextAfterPartialRemoval() {
        let ring: RingBuffer = [1, 2, 3, 4, 5]
        _ = ring.removeFirst()
        _ = ring.removeLast()
        // remaining: [2, 3, 4]
        var collected: [Int] = []
        while let v = ring.next() {
            collected.append(v)
        }
        #expect(collected == [2, 3, 4])
    }

}


// MARK: - Description

@Suite
struct RingBufferDescriptionTests {

    @Test
    func description() {
        let array = [1, 2, 3, 4, 5]
        let ring: RingBuffer = [1, 2, 3, 4, 5]
        #expect(array.description == ring.description)
        #expect(Array(ring) == array)
    }

    @Test
    func descriptionEmpty() {
        let ring = RingBuffer<Int>()
        #expect(ring.description == "[]")
    }

    @Test
    func descriptionSingle() {
        let ring: RingBuffer = [99]
        #expect(ring.description == "[99]")
    }

    @Test
    func descriptionAfterWrapAround() {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        ring.append(1)
        ring.append(2)
        ring.append(3)
        ring.append(4)
        ring.removeFirst()
        ring.removeFirst()
        ring.append(5)
        ring.append(6)
        // [3, 4, 5, 6]
        #expect(ring.description == "[3, 4, 5, 6]")
    }

}


// MARK: - String Elements

@Suite
struct RingBufferStringElementTests {

    @Test
    func stringElements() {
        let ring = RingBuffer<String>(minimumCapacity: 4)
        ring.append("alice")
        ring.append("bob")
        ring.append("charlie")
        #expect(ring.first == "alice")
        #expect(ring.last == "charlie")
        #expect(ring.removeFirst() == "alice")
        #expect(ring.removeLast() == "charlie")
        #expect(ring.first == "bob")
        #expect(ring.removeFirst() == "bob")
        #expect(ring.isEmpty)
    }

    @Test
    func stringPrepend() {
        let ring = RingBuffer<String>(minimumCapacity: 4)
        ring.prepend("b")
        ring.prepend("a")
        #expect(ring.first == "a")
        #expect(ring.last == "b")
    }

    @Test
    func stringGrow() {
        let ring = RingBuffer<String>(minimumCapacity: 2)
        ring.append("one")
        ring.append("two")
        ring.append("three") // triggers grow
        #expect(ring.count == 3)
        #expect(ring.first == "one")
        #expect(ring.last == "three")
    }

}


// MARK: - Class Payload

@Suite
struct RingBufferClassPayloadTests {

    @Test
    func classPayloadAppendRemove() {
        let ring = RingBuffer<RBTestObject>(minimumCapacity: 4)
        let obj1 = RBTestObject(id: 1)
        let obj2 = RBTestObject(id: 2)
        let obj3 = RBTestObject(id: 3)

        ring.append(obj1)
        ring.append(obj2)
        ring.append(obj3)

        #expect(ring.count == 3)
        #expect(ring.first?.id == 1)
        #expect(ring.last?.id == 3)

        #expect(ring.removeFirst() === obj1)
        #expect(ring.removeFirst() === obj2)
        #expect(ring.removeFirst() === obj3)
        #expect(ring.isEmpty)
    }

    @Test
    func classPayloadPrepend() {
        let ring = RingBuffer<RBTestObject>(minimumCapacity: 4)
        let obj1 = RBTestObject(id: 1)
        let obj2 = RBTestObject(id: 0)

        ring.append(obj1)
        ring.prepend(obj2)

        #expect(ring.first === obj2)
        #expect(ring.last === obj1)
    }

    @Test
    func classPayloadGrowPreservesIdentity() {
        let ring = RingBuffer<RBTestObject>(minimumCapacity: 2)
        let objects = (0..<10).map { RBTestObject(id: $0) }

        for obj in objects {
            ring.append(obj)
        }

        #expect(ring.count == 10)
        #expect(ring.first === objects[0])
        #expect(ring.last === objects[9])
    }

    @Test
    func classPayloadReferenceMutability() {
        let obj = RBTestObject(id: 42, score: 1.0)
        let ring = RingBuffer<RBTestObject>(minimumCapacity: 4)
        ring.append(obj)

        obj.score = 99.0

        #expect(ring.first?.score == 99.0)
        #expect(ring.first === obj)
    }

    @Test
    func classPayloadRemoveLast() {
        let ring = RingBuffer<RBTestObject>(minimumCapacity: 4)
        let obj1 = RBTestObject(id: 1)
        let obj2 = RBTestObject(id: 2)

        ring.append(obj1)
        ring.append(obj2)

        #expect(ring.removeLast() === obj2)
        #expect(ring.removeLast() === obj1)
        #expect(ring.isEmpty)
    }

    @Test
    func classPayloadForEach() {
        let obj1 = RBTestObject(id: 10)
        let obj2 = RBTestObject(id: 20)
        let obj3 = RBTestObject(id: 30)
        let ring: RingBuffer<RBTestObject> = [obj1, obj2, obj3]

        var seen: [Int] = []
        ring.forEach { seen.append($0.id) }
        #expect(seen == [10, 20, 30])
    }

    @Test
    func classPayloadForEachAfterWrapAround() {
        let ring = RingBuffer<RBTestObject>(minimumCapacity: 4)
        let objects = (0..<4).map { RBTestObject(id: $0) }
        for obj in objects { ring.append(obj) }

        ring.removeFirst()
        ring.removeFirst()
        ring.append(RBTestObject(id: 100))
        ring.append(RBTestObject(id: 200))
        // remaining: objects[2], objects[3], id:100, id:200

        var seen: [Int] = []
        ring.forEach { seen.append($0.id) }
        #expect(seen == [2, 3, 100, 200])
    }

}


// MARK: - Edge Cases

@Suite
struct RingBufferEdgeCaseTests {

    @Test
    func emptyBufferDeinit() {
        // must not crash when deallocating an empty buffer
        let ring = RingBuffer<Int>(minimumCapacity: 8)
        #expect(ring.isEmpty)
        #expect(ring.count == 0)
    }

    @Test
    func singleElement() {
        let ring = RingBuffer<Double>(minimumCapacity: 1)
        ring.append(3.14)
        #expect(ring.first == 3.14)
        #expect(ring.last == 3.14)
        #expect(ring.count == 1)

        #expect(ring.removeFirst() == 3.14)
        #expect(ring.isEmpty)

        // re-append after empty
        ring.append(2.71)
        #expect(ring.first == 2.71)
        #expect(ring.removeLast() == 2.71)
    }

    @Test
    func largeBufferGrow() {
        let ring = RingBuffer<Int>(minimumCapacity: 2)
        for i in 0..<1000 {
            ring.append(i)
        }
        #expect(ring.count == 1000)
        #expect(ring.first == 0)
        #expect(ring.last == 999)

        var extracted: [Int] = []
        while let v = ring.next() {
            extracted.append(v)
        }
        #expect(extracted == Array(0..<1000))
    }

    @Test
    func appendRemoveInterleavedStress() {
        let ring = RingBuffer<Int>(minimumCapacity: 4)
        for i in 0..<1000 {
            ring.append(i)
            if i % 2 == 0 {
                _ = ring.removeFirst()
            }
        }
        // Buffer should still be internally consistent
        #expect(ring.count >= 0)
        var seen: [Int] = []
        ring.forEach { seen.append($0) }
        #expect(seen.count == ring.count)
    }

    @Test
    func alternatingRemoveFirstAndLast() {
        let ring: RingBuffer = [1, 2, 3, 4, 5, 6]
        #expect(ring.removeFirst() == 1)
        #expect(ring.removeLast() == 6)
        #expect(ring.removeFirst() == 2)
        #expect(ring.removeLast() == 5)
        #expect(ring.removeFirst() == 3)
        #expect(ring.removeLast() == 4)
        #expect(ring.isEmpty)
    }

    @Test
    func repeatedGrow() {
        let ring = RingBuffer<Int>(minimumCapacity: 1)
        for i in 0..<100 {
            ring.append(i)
        }
        #expect(ring.count == 100)
        #expect(ring.capacity == 128)
        #expect(ring.first == 0)
        #expect(ring.last == 99)
    }

    @Test
    func capacityAlwaysPowerOfTwo() {
        let ring = RingBuffer<Int>(minimumCapacity: 1)
        var previousCapacity = ring.capacity
        #expect(previousCapacity & (previousCapacity - 1) == 0)

        for i in 0..<200 {
            ring.append(i)
            if ring.capacity != previousCapacity {
                #expect(ring.capacity & (ring.capacity - 1) == 0)
                previousCapacity = ring.capacity
            }
        }
    }

}
