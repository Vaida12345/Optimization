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


/// Verifies the heap property holds for every parent-child pair.
private func verifyHeapProperty<T: Comparable>(_ heap: Heap<T>) -> Bool {
    let contents = heap.contents
    for i in 0..<contents.count {
        let left = Heap<T>.leftChildIndex(of: i)
        let right = left + 1
        if left < contents.count {
            if heap.heapType == .maxHeap {
                if contents[i] < contents[left] { return false }
            } else {
                if contents[i] > contents[left] { return false }
            }
        }
        if right < contents.count {
            if heap.heapType == .maxHeap {
                if contents[i] < contents[right] { return false }
            } else {
                if contents[i] > contents[right] { return false }
            }
        }
    }
    return true
}


// MARK: - Basic Properties

@Suite
struct HeapBasicTests {

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func emptyHeap(type: Heap<Int>.HeapType) async throws {
        let heap: Heap<Int> = []
        #expect(heap.isEmpty)
        #expect(heap.count == 0)
    }

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func count(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type)
        #expect(heap.count == 0)
        #expect(heap.isEmpty)

        heap.append(1)
        #expect(heap.count == 1)
        #expect(!heap.isEmpty)

        heap.append(contentsOf: [2, 3, 4])
        #expect(heap.count == 4)
    }

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func first(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type)
        #expect(heap.first == nil)

        heap.append(42)
        #expect(heap.first == 42)
    }

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func heapTypeEnum(type: Heap<Int>.HeapType) {
        #expect(type == type)
        #expect(type != (type == .maxHeap ? Heap<Int>.HeapType.minHeap : .maxHeap))
    }

}


// MARK: - Init

@Suite
struct HeapInitTests {

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func initFromEmptyArray(type: Heap<Int>.HeapType) {
        let heap = Heap<Int>(type, from: [])
        #expect(heap.isEmpty)
        #expect(heap.count == 0)
    }

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func initFromArray(type: Heap<Int>.HeapType) {
        let heap = Heap<Int>(type, from: [3, 1, 4, 1, 5, 9, 2, 6])
        #expect(heap.count == 8)
        #expect(verifyHeapProperty(heap))
    }

    @Test
    func initFromArrayLiteral() {
        let maxHeap: Heap<Int> = [3, 1, 4]
        #expect(maxHeap.count == 3)
        #expect(maxHeap.heapType == .maxHeap)
        #expect(verifyHeapProperty(maxHeap))
    }

    @Test
    func initDefaultType() {
        let heap = Heap<Int>()
        #expect(heap.heapType == .maxHeap)
        #expect(heap.isEmpty)
    }

}


// MARK: - Append

@Suite
struct HeapAppendTests {

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func simpleAppend(type: Heap<Int>.HeapType) async throws {
        var heap = Heap<Int>(type)
        heap.append(1)
        heap.append(100)
        heap.append(2)
        heap.append(50)

        #expect(heap.count == 4)
        #expect(heap.first == (type == .maxHeap ? 100 : 1))
        #expect(verifyHeapProperty(heap))

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
    func appendSingleElement(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type)
        heap.append(10)
        #expect(heap.count == 1)
        #expect(heap.first == 10)
        #expect(heap.removeFirst() == 10)
        #expect(heap.isEmpty)
        #expect(heap.removeFirst() == nil)
        #expect(verifyHeapProperty(Heap<Int>(type)))
    }

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func appendDuplicateValues(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type)
        heap.append(contentsOf: [5, 5, 3, 3, 7, 7])

        let sorted = Array(heap)
        let expected = [5, 5, 3, 3, 7, 7].sorted(by: { type == .maxHeap ? $0 > $1 : $0 < $1 })
        #expect(sorted == expected)
    }

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func appendContentsOfSequence(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type)
        heap.append(contentsOf: stride(from: 0, to: 10, by: 1))
        #expect(heap.count == 10)
        #expect(verifyHeapProperty(heap))
    }

}


// MARK: - Remove

@Suite
struct HeapRemoveTests {

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func removeFirst(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type, from: [3, 1, 4, 1, 5, 9, 2, 6])
        var sorted: [Int] = []
        while let v = heap.removeFirst() {
            sorted.append(v)
        }
        let expected = [3, 1, 4, 1, 5, 9, 2, 6].sorted(by: { type == .maxHeap ? $0 > $1 : $0 < $1 })
        #expect(sorted == expected)
    }

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func removeFirstFromSingleElement(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type)
        heap.append(10)
        #expect(heap.removeFirst() == 10)
        #expect(heap.isEmpty)
        #expect(heap.removeFirst() == nil)
    }

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func removeFirstFromEmpty(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type)
        #expect(heap.removeFirst() == nil)
    }

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func removeFirstPreservesHeapProperty(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type, from: (0..<100).map { _ in Int.random(in: 0..<1000) })
        for _ in 0..<50 {
            _ = heap.removeFirst()
            #expect(verifyHeapProperty(heap))
        }
    }

}


// MARK: - Peek / RemoveAll

@Suite
struct HeapPeekRemoveAllTests {

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
    func removeAllThenReuse(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type)
        heap.append(contentsOf: [5, 3, 7])
        heap.removeAll()

        heap.append(99)
        #expect(heap.count == 1)
        #expect(heap.first == 99)
    }

}


// MARK: - Internal Methods

@Suite
struct HeapInternalTests {

    // MARK: parentIndex / leftChildIndex

    @Test
    func parentIndex() {
        #expect(Heap<Int>.parentIndex(of: 1) == 0)
        #expect(Heap<Int>.parentIndex(of: 2) == 0)
        #expect(Heap<Int>.parentIndex(of: 3) == 1)
        #expect(Heap<Int>.parentIndex(of: 4) == 1)
        #expect(Heap<Int>.parentIndex(of: 5) == 2)
        #expect(Heap<Int>.parentIndex(of: 6) == 2)
    }

    @Test
    func leftChildIndex() {
        #expect(Heap<Int>.leftChildIndex(of: 0) == 1)
        #expect(Heap<Int>.leftChildIndex(of: 1) == 3)
        #expect(Heap<Int>.leftChildIndex(of: 2) == 5)
        #expect(Heap<Int>.leftChildIndex(of: 3) == 7)
    }

    // MARK: isInOrder

    @Test
    func isInOrderMaxHeap() {
        let heap = Heap<Int>(.maxHeap)
        #expect(heap.isInOrder(5, 3))
        #expect(!heap.isInOrder(3, 5))
        #expect(!heap.isInOrder(5, 5))
    }

    @Test
    func isInOrderMinHeap() {
        let heap = Heap<Int>(.minHeap)
        #expect(heap.isInOrder(3, 5))
        #expect(!heap.isInOrder(5, 3))
        #expect(!heap.isInOrder(5, 5))
    }

    // MARK: upHeap

    @Test
    func upHeapMax() {
        var heap = Heap<Int>(.maxHeap)
        // [5, 3, 1, 10] — 10 at index 3 should bubble to root
        heap.contents = [5, 3, 1, 10]
        heap.upHeap(at: 3)
        #expect(heap.contents[0] == 10)
        #expect(verifyHeapProperty(heap))
    }

    @Test
    func upHeapMin() {
        var heap = Heap<Int>(.minHeap)
        // [5, 10, 8, 1] — first 3 elements form a valid min-heap, 1 at index 3 should bubble to root
        heap.contents = [5, 10, 8, 1]
        heap.upHeap(at: 3)
        #expect(heap.contents[0] == 1)
        #expect(verifyHeapProperty(heap))
    }

    @Test
    func upHeapNoChange() {
        var heap = Heap<Int>(.maxHeap)
        // already valid: parent 10 >= child 5
        heap.contents = [10, 5, 3]
        heap.upHeap(at: 1)
        #expect(heap.contents[0] == 10)
        #expect(verifyHeapProperty(heap))
    }

    @Test
    func upHeapAtRoot() {
        var heap = Heap<Int>(.maxHeap)
        heap.contents = [10, 5, 3]
        heap.upHeap(at: 0)
        #expect(heap.contents[0] == 10)
        #expect(verifyHeapProperty(heap))
    }

    // MARK: downHeap

    @Test
    func downHeapMax() {
        var heap = Heap<Int>(.maxHeap)
        // [1, 5, 3] — root 1 is less than children, should sink
        heap.contents = [1, 5, 3]
        heap.downHeap(at: 0)
        #expect(heap.contents[0] == 5)
        #expect(verifyHeapProperty(heap))
    }

    @Test
    func downHeapMin() {
        var heap = Heap<Int>(.minHeap)
        // [10, 3, 5] — root 10 is greater than children, should sink
        heap.contents = [10, 3, 5]
        heap.downHeap(at: 0)
        #expect(heap.contents[0] == 3)
        #expect(verifyHeapProperty(heap))
    }

    @Test
    func downHeapNoChange() {
        var heap = Heap<Int>(.maxHeap)
        // already valid: root 10 > children 5, 3
        heap.contents = [10, 5, 3]
        heap.downHeap(at: 0)
        #expect(heap.contents[0] == 10)
        #expect(verifyHeapProperty(heap))
    }

    @Test
    func downHeapLeaf() {
        var heap = Heap<Int>(.maxHeap)
        heap.contents = [10, 5, 3, 1]
        heap.downHeap(at: 3) // leaf, no children
        #expect(heap.contents[3] == 1)
        #expect(verifyHeapProperty(heap))
    }

    @Test
    func downHeapMaxPrefersLargerChild() {
        var heap = Heap<Int>(.maxHeap)
        // [3, 5, 10] — root should swap with 10 (right child, larger)
        heap.contents = [3, 5, 10]
        heap.downHeap(at: 0)
        #expect(heap.contents[0] == 10)
        #expect(verifyHeapProperty(heap))
    }

    @Test
    func downHeapMinPrefersSmallerChild() {
        var heap = Heap<Int>(.minHeap)
        // [8, 5, 3] — root should swap with 3 (right child, smaller)
        heap.contents = [8, 5, 3]
        heap.downHeap(at: 0)
        #expect(heap.contents[0] == 3)
        #expect(verifyHeapProperty(heap))
    }

    @Test
    func downHeapOnlyLeftChild() {
        var heap = Heap<Int>(.maxHeap)
        // [2, 5] — only left child exists
        heap.contents = [2, 5]
        heap.downHeap(at: 0)
        #expect(heap.contents[0] == 5)
        #expect(verifyHeapProperty(heap))
    }

    // MARK: heapify

    @Test
    func heapifyMax() {
        var heap = Heap<Int>(.maxHeap)
        heap.contents = [3, 1, 4, 1, 5, 9, 2, 6]
        heap.heapify()
        #expect(verifyHeapProperty(heap))
        #expect(heap.contents[0] == 9)
    }

    @Test
    func heapifyMin() {
        var heap = Heap<Int>(.minHeap)
        heap.contents = [3, 1, 4, 1, 5, 9, 2, 6]
        heap.heapify()
        #expect(verifyHeapProperty(heap))
        #expect(heap.contents[0] == 1)
    }

    @Test
    func heapifyEmpty() {
        var heap = Heap<Int>(.maxHeap)
        heap.contents = []
        heap.heapify()
        #expect(heap.contents == [])
    }

    @Test
    func heapifySingleElement() {
        var heap = Heap<Int>(.maxHeap)
        heap.contents = [42]
        heap.heapify()
        #expect(heap.contents == [42])
    }

    @Test
    func heapifyAlreadySorted() {
        var heap = Heap<Int>(.maxHeap)
        heap.contents = [9, 5, 6, 1, 3, 2, 4] // valid max-heap
        heap.heapify()
        #expect(verifyHeapProperty(heap))
        #expect(heap.contents[0] == 9)
    }

}


// MARK: - IteratorProtocol / Sequence

@Suite
struct HeapIteratorTests {

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func nextConsumesCopy(type: Heap<Int>.HeapType) {
        let heap = Heap<Int>(type, from: [3, 1, 4, 1, 5, 9, 2, 6])

        // next() calls removeFirst() on a copy since Heap is a struct
        var iterator = heap
        var result: [Int] = []
        while let v = iterator.next() {
            result.append(v)
        }

        let expected = [3, 1, 4, 1, 5, 9, 2, 6].sorted(by: { type == .maxHeap ? $0 > $1 : $0 < $1 })
        #expect(result == expected)
        // original heap intact
        #expect(heap.count == 8)
    }

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func forInDoesNotConsume(type: Heap<Int>.HeapType) {
        let heap = Heap<Int>(type, from: [5, 2, 8, 1])

        var result: [Int] = []
        for element in heap {
            result.append(element)
        }

        let expected = [5, 2, 8, 1].sorted(by: { type == .maxHeap ? $0 > $1 : $0 < $1 })
        #expect(result == expected)
        // original heap intact (struct semantics)
        #expect(heap.count == 4)
    }

    @Test
    func mapOnHeap() {
        let heap = Heap<Int>(.maxHeap, from: [3, 1, 4])
        let doubled = heap.map { $0 * 2 }
        #expect(doubled == [4, 3, 1].map { $0 * 2 })
        // original intact
        #expect(heap.count == 3)
    }

}


// MARK: - Description

@Suite
struct HeapDescriptionTests {

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

    @Test
    func descriptionEmpty() {
        let heap = Heap<Int>(.maxHeap)
        #expect(heap.description == "[]")
    }

    @Test
    func descriptionSingleElement() {
        var heap = Heap<Int>(.maxHeap)
        heap.append(42)
        #expect(heap.description == "[42]")
    }

}


// MARK: - Array from Heap

@Suite
struct HeapArrayInitTests {

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func arrayInit(type: Heap<Int>.HeapType) {
        let heap = Heap<Int>(type, from: [3, 1, 4, 1, 5, 9, 2, 6])
        let array = Array(heap)
        let expected = [3, 1, 4, 1, 5, 9, 2, 6].sorted(by: { type == .maxHeap ? $0 > $1 : $0 < $1 })
        #expect(array == expected)
    }

    @Test
    func arrayInitEmpty() {
        let heap = Heap<Int>(.maxHeap)
        #expect(Array(heap) == [])
    }

    @Test
    func arrayInitSingle() {
        var heap = Heap<Int>(.minHeap)
        heap.append(42)
        #expect(Array(heap) == [42])
    }

}


// MARK: - Sequence Extensions: min(k:) / max(k:)

@Suite
struct HeapSequenceExtensionTests {

    @Test
    func sequenceMinK() {
        let array = [3, 1, 4, 1, 5, 9, 2, 6]
        #expect(array.min(k: 1) == array.min())
        #expect(array.min(k: 2) == array.sorted()[1])
        #expect(array.min(k: 3) == array.sorted()[2])
        #expect(array.min(k: 4) == array.sorted()[3])
    }

    @Test
    func sequenceMaxK() {
        let array = [3, 1, 4, 1, 5, 9, 2, 6]
        #expect(array.max(k: 1) == array.max())
        #expect(array.max(k: 2) == array.sorted(by: >)[1])
        #expect(array.max(k: 3) == array.sorted(by: >)[2])
        #expect(array.max(k: 4) == array.sorted(by: >)[3])
    }

    @Test
    func minKBeyondCount() {
        let array = [3, 1, 4]
        #expect(array.min(k: 100) == array.max())
        #expect(array.max(k: 100) == array.min())
    }

    @Test
    func emptySequenceMinK() {
        let empty: [Int] = []
        #expect(empty.min(k: 1) == nil)
        #expect(empty.max(k: 1) == nil)
    }

    @Test
    func minKWithDuplicates() {
        let array = [5, 5, 3, 3, 7, 7]
        #expect(array.min(k: 1) == 3)
        #expect(array.min(k: 2) == 3)
        #expect(array.min(k: 3) == 5)
        #expect(array.min(k: 4) == 5)
        #expect(array.min(k: 5) == 7)
        #expect(array.min(k: 6) == 7)
    }

    @Test
    func maxKWithDuplicates() {
        let array = [5, 5, 3, 3, 7, 7]
        #expect(array.max(k: 1) == 7)
        #expect(array.max(k: 2) == 7)
        #expect(array.max(k: 3) == 5)
        #expect(array.max(k: 4) == 5)
        #expect(array.max(k: 5) == 3)
        #expect(array.max(k: 6) == 3)
    }

    @Test
    func minKSingleElement() {
        #expect([42].min(k: 1) == 42)
        #expect([42].min(k: 2) == 42)
    }

    @Test
    func maxKSingleElement() {
        #expect([42].max(k: 1) == 42)
        #expect([42].max(k: 2) == 42)
    }

}


// MARK: - Append ContentsOf

@Suite
struct HeapAppendContentsOfTests {

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

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func appendContentsOfEmpty(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type)
        heap.append(contentsOf: EmptyCollection<Int>())
        #expect(heap.isEmpty)
    }

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func appendContentsOfSingle(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type)
        heap.append(contentsOf: [42])
        #expect(heap.count == 1)
        #expect(heap.first == 42)
    }

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func appendContentsOfAlreadySorted(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type)
        let sorted = type == .maxHeap
            ? [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
            : [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        heap.append(contentsOf: sorted)
        #expect(verifyHeapProperty(heap))
    }

}


// MARK: - String Elements

@Suite
struct HeapStringElementTests {

    @Test(arguments: [Heap<String>.HeapType.maxHeap, .minHeap])
    func stringElements(type: Heap<String>.HeapType) {
        var heap = Heap<String>(type)
        heap.append("zebra")
        heap.append("apple")
        heap.append("mango")

        let sorted = Array(heap)
        #expect(sorted == (type == .maxHeap ? ["zebra", "mango", "apple"] : ["apple", "mango", "zebra"]))
    }

    @Test
    func stringHeapify() {
        var heap = Heap<String>(.maxHeap)
        heap.contents = ["cat", "ant", "bee", "dog"]
        heap.heapify()
        #expect(verifyHeapProperty(heap))
    }

}


// MARK: - Class Payload

@Suite
struct HeapClassPayloadTests {

    @Test(arguments: [Heap<HeapTestObject>.HeapType.maxHeap, .minHeap])
    func classPayload(type: Heap<HeapTestObject>.HeapType) async throws {
        var heap = Heap<HeapTestObject>(type)
        _ = type // used by arguments
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
        #expect(verifyHeapProperty(heap))

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

    @Test
    func classPayloadIsInOrder() {
        let heap = Heap<HeapTestObject>(.maxHeap)
        #expect(heap.isInOrder(HeapTestObject(id: 5), HeapTestObject(id: 3)))
        #expect(!heap.isInOrder(HeapTestObject(id: 3), HeapTestObject(id: 5)))
    }

}


// MARK: - Large Data / Edge Cases

@Suite
struct HeapEdgeCaseTests {

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

    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func interleavedAppendAndRemove(type: Heap<Int>.HeapType) {
        var heap = Heap<Int>(type)
        for i in 0..<100 {
            heap.append(i)
            if i % 3 == 0 {
                _ = heap.removeFirst()
            }
        }
        #expect(verifyHeapProperty(heap))
    }

    @Test
    func heapPropertyAfterEveryAppend() {
        var heap = Heap<Int>(.maxHeap)
        let values = (0..<100).map { _ in Int.random(in: 0..<1000) }
        for value in values {
            heap.append(value)
            #expect(verifyHeapProperty(heap))
        }
    }

    @Test
    func heapPropertyAfterEveryRemove() {
        var heap = Heap<Int>(.maxHeap, from: (0..<100).map { _ in Int.random(in: 0..<1000) })
        let count = heap.count
        for _ in 0..<count {
            _ = heap.removeFirst()
            if !heap.isEmpty {
                #expect(verifyHeapProperty(heap))
            }
        }
    }

    @Test
    func negativeValuesMaxHeap() {
        var heap = Heap<Int>(.maxHeap)
        heap.append(contentsOf: [-5, -1, -10, -3, -7])
        #expect(heap.first == -1)
        #expect(Array(heap) == [-1, -3, -5, -7, -10])
    }

    @Test
    func negativeValuesMinHeap() {
        var heap = Heap<Int>(.minHeap)
        heap.append(contentsOf: [-5, -1, -10, -3, -7])
        #expect(heap.first == -10)
        #expect(Array(heap) == [-10, -7, -5, -3, -1])
    }

    @Test
    func minKMaxKWithLargeK() {
        let array = [5, 3, 7]
        #expect(array.min(k: 5) == 7)
        #expect(array.max(k: 5) == 3)
    }

}
