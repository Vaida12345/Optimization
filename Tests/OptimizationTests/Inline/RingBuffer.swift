//
//  RingBuffer.swift
//  Optimization
//
//  Created by Vaida on 2025-05-09.
//

import Testing
@testable
import Optimization


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
    
}
