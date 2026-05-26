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


@Suite
struct RingBufferTests {
    
    @Test
    func testEmpty() {
        let ring = RingBuffer<Int>()
        #expect(ring.isEmpty)
        #expect(ring.count == 0)
        #expect(ring.first == nil)
        #expect(ring.last == nil)
    }
    
    @Test
    func testAppendAndRemoveFirst() {
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
    func testAppendAndRemoveLast() {
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
    func testPrependAndWrapAround() {
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
    func testGrowCapacityDoubling() {
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
    func testDescription() {
        let array = [1, 2, 3, 4, 5]
        let ring: RingBuffer = [1, 2, 3, 4, 5]
        #expect(array.description == ring.description)
        #expect(Array(ring) == array)
    }

    @Test
    func testStringElements() {
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
    func testInterleavedPrependAppendRemove() {
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
    func testRemoveLastThenAppend() {
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
    func testWrapAroundWithPrepend() {
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
    func testEmptyBufferDeinit() {
        // must not crash when deallocating an empty buffer
        let ring = RingBuffer<Int>(minimumCapacity: 8)
        #expect(ring.isEmpty)
        #expect(ring.count == 0)
    }

    @Test
    func testSingleElement() {
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
    func testCapacityIsPowerOfTwo() {
        let ring = RingBuffer<Int>(minimumCapacity: 3)
        #expect(ring.capacity == 4)
        #expect(ring.capacity & (ring.capacity - 1) == 0) // power-of-two check

        let ring2 = RingBuffer<Int>(minimumCapacity: 100)
        #expect(ring2.capacity == 128)
    }

    @Test
    func testLargeBufferGrow() {
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

}
