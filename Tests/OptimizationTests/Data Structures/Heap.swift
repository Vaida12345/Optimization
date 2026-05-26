//
//  Heap.swift
//  Essentials
//
//  Created by Vaida on 12/1/24.
//

import Testing
@testable
import Optimization


final class HeapTestObject: Comparable, CustomStringConvertible {
    let id: Int

    init(id: Int) {
        self.id = id
    }

    static func == (lhs: HeapTestObject, rhs: HeapTestObject) -> Bool { lhs.id == rhs.id }
    static func < (lhs: HeapTestObject, rhs: HeapTestObject) -> Bool { lhs.id < rhs.id }
    var description: String { "Obj(\(id))" }
}


@Suite
struct HeapTests {
    
    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func emptyHeap(type: Heap<Int>.HeapType) async throws {
        let heap: Heap<Int> = []
        #expect(heap.isEmpty)
        #expect(heap.count == 0)
    }
    
    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func simpleAppend(type: Heap<Int>.HeapType) async throws {
        var heap = Heap<Int>(type)
        heap.append(1)
        heap.append(100)
        heap.append(2)
        heap.append(50)
        
        #expect(heap.count == 4)
        #expect(heap.first == (type == .maxHeap ? 100 : 1))
        #expect(heap.contains(1))
        #expect(heap.contains(100))
        #expect(heap.contains(2))
        #expect(heap.contains(50))
        
        if type == .maxHeap {
            #expect(heap.removeFirst() == 100)
            #expect(heap.removeFirst() == 50)
            #expect(heap.removeFirst() == 2)
            #expect(heap.removeFirst() == 1)
            #expect(heap.removeFirst() == nil)
        } else {
            #expect(heap.removeFirst() == 1)
            #expect(heap.removeFirst() == 2)
            #expect(heap.removeFirst() == 50)
            #expect(heap.removeFirst() == 100)
            #expect(heap.removeFirst() == nil)
        }
    }
    
    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func sequenceAppend(type: Heap<Int>.HeapType) async throws {
        var heap = Heap<Int>(type)
        var array: [Int] = []
        while array.count < 10 {
            array.append(Int.random(in: Int.min ..< Int.max))
        }
        heap.append(contentsOf: array)
        let sorted = array.sorted(by: { type == .maxHeap ? $0 > $1 : $0 < $1 })
        
        for (lhs, rhs) in zip(sorted, heap) {
            #expect(lhs == rhs)
        }
        
        let second = Heap(type, from: array)
        for (lhs, rhs) in zip(sorted, second) {
            #expect(lhs == rhs)
        }
        
        #expect(Array(heap) == sorted)
    }
    
    @Test
    func sequenceMin() {
        var array: [Int] = []
        while array.count < 10 {
            array.append(Int.random(in: Int.min ..< Int.max))
        }
        
        #expect(array.min(k: 1) == array.min())
        #expect(array.min(k: 2) == array.sorted()[1])
        #expect(array.min(k: 3) == array.sorted()[2])
        #expect(array.min(k: 4) == array.sorted()[3])
        
        #expect(array.min(k: 100) == array.max())
    }
    
    @Test
    func sequenceMax() {
        var array: [Int] = []
        while array.count < 10 {
            array.append(Int.random(in: Int.min ..< Int.max))
        }
        
        #expect(array.max(k: 1) == array.max())
        #expect(array.max(k: 2) == array.sorted(by: >)[1])
        #expect(array.max(k: 3) == array.sorted(by: >)[2])
        #expect(array.max(k: 4) == array.sorted(by: >)[3])
        
        #expect(array.min(k: 100) == array.max())
    }
    
    @Test
    func description() {
        var heap = Heap<Int>(.minHeap)
        heap.append(1)
        heap.append(100)
        heap.append(2)
        heap.append(50)

        #expect(heap.description == "[1, 2, 50, 100]")
        #expect(Array(heap) == [1, 2, 50, 100])
    }

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func peek(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type)
        #expect(heap.peek() == nil)

        heap.append(42)
        #expect(heap.peek() == 42)
        #expect(heap.count == 1) // peek must not mutate
    }

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func removeAll(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type)
        heap.append(contentsOf: [5, 3, 7, 1])
        #expect(heap.count == 4)

        heap.removeAll()
        #expect(heap.isEmpty)
        #expect(heap.count == 0)
        #expect(heap.peek() == nil)
    }

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func singleElement(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type)
        heap.append(10)
        #expect(heap.count == 1)
        #expect(heap.first == 10)
        #expect(heap.removeFirst() == 10)
        #expect(heap.isEmpty)
        #expect(heap.removeFirst() == nil)
    }

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func duplicateValues(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type)
        heap.append(contentsOf: [5, 5, 3, 3, 7, 7])

        let sorted = Array(heap)
        let expected = [5, 5, 3, 3, 7, 7].sorted(by: { type == .maxHeap ? $0 > $1 : $0 < $1 })
        #expect(sorted == expected)
    }

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func largeHeap(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type)
        let values = (0..<10_000).map { _ in Int.random(in: Int.min ..< Int.max) }
        heap.append(contentsOf: values)

        var extracted: [Int] = []
        while let v = heap.next() {
            extracted.append(v)
        }

        let expected = values.sorted(by: { type == .maxHeap ? $0 > $1 : $0 < $1 })
        #expect(extracted == expected)
    }

    @Test
    func emptySequenceMinK() {
        let empty: [Int] = []
        #expect(empty.min(k: 1) == nil)
        #expect(empty.max(k: 1) == nil)
    }

    @Test(arguments: [Heap<String>.HeapType.maxHeap, .minHeap])
    func stringElements(type: Heap<String>.HeapType) {
        var heap = Heap<String>(type)
        heap.append("zebra")
        heap.append("apple")
        heap.append("mango")

        let sorted = Array(heap)
        #expect(sorted == (type == .maxHeap ? ["zebra", "mango", "apple"] : ["apple", "mango", "zebra"]))
    }

    @Test(arguments: [Heap<HeapTestObject>.HeapType.maxHeap, .minHeap])
    func classPayload(type: Heap<HeapTestObject>.HeapType) async throws {
        var heap = Heap<HeapTestObject>(type)
        let obj1 = HeapTestObject(id: 1)
        let obj2 = HeapTestObject(id: 100)
        let obj3 = HeapTestObject(id: 2)
        let obj4 = HeapTestObject(id: 50)

        heap.append(obj1)
        heap.append(obj2)
        heap.append(obj3)
        heap.append(obj4)

        #expect(heap.count == 4)
        #expect(heap.first?.id == (type == .maxHeap ? 100 : 1))
        #expect(heap.contains(obj1))
        #expect(heap.contains(obj2))
        #expect(heap.contains(obj3))
        #expect(heap.contains(obj4))

        if type == .maxHeap {
            #expect(heap.removeFirst()?.id == 100)
            #expect(heap.removeFirst()?.id == 50)
            #expect(heap.removeFirst()?.id == 2)
            #expect(heap.removeFirst()?.id == 1)
            #expect(heap.removeFirst() == nil)
        } else {
            #expect(heap.removeFirst()?.id == 1)
            #expect(heap.removeFirst()?.id == 2)
            #expect(heap.removeFirst()?.id == 50)
            #expect(heap.removeFirst()?.id == 100)
            #expect(heap.removeFirst() == nil)
        }
    }

    @Test(arguments: [Heap<HeapTestObject>.HeapType.maxHeap, .minHeap])
    func classPayloadLargeHeap(type: Heap<HeapTestObject>.HeapType) async throws {
        var heap = Heap<HeapTestObject>(type)
        let objects = (0..<1000).map { HeapTestObject(id: $0) }
        heap.append(contentsOf: objects)

        var extracted: [Int] = []
        while let v = heap.next() {
            extracted.append(v.id)
        }

        let expected = (0..<1000).sorted(by: { type == .maxHeap ? $0 > $1 : $0 < $1 })
        #expect(extracted == expected)
    }

    @Test(arguments: [Heap<HeapTestObject>.HeapType.maxHeap, .minHeap])
    func classPayloadReferenceIdentity(type: Heap<HeapTestObject>.HeapType) async throws {
        var heap = Heap<HeapTestObject>(type)
        let obj = HeapTestObject(id: 42)
        heap.append(obj)

        let peeked = heap.peek()
        #expect(peeked === obj)
        #expect(peeked?.id == 42)
    }

    @Test
    func classPayloadDescription() {
        var heap = Heap<HeapTestObject>(.minHeap)
        heap.append(HeapTestObject(id: 1))
        heap.append(HeapTestObject(id: 100))
        heap.append(HeapTestObject(id: 2))
        heap.append(HeapTestObject(id: 50))

        #expect(heap.description == "[Obj(1), Obj(2), Obj(50), Obj(100)]")
    }

}
