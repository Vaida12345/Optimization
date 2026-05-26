//
//  Deque.swift
//  Optimization
//
//  Created by Vaida on 2025-05-09.
//

import Testing
@testable
import Optimization


final class DequeTestObject: Equatable, CustomStringConvertible {
    let id: Int
    var tag: String

    init(id: Int, tag: String = "") {
        self.id = id
        self.tag = tag
    }

    static func == (lhs: DequeTestObject, rhs: DequeTestObject) -> Bool { lhs.id == rhs.id && lhs.tag == rhs.tag }
    var description: String { "Obj(\(id))" }
}


@Suite
struct DequeTests {
    
    @Test func testEmpty() {
        let deque = Deque<Int>()
        #expect(deque.front == nil)
        #expect(deque.back == nil)
        #expect(deque.isEmpty)
        #expect(deque.count == 0)
        #expect(deque.first == nil)
        #expect(deque.last == nil)
    }
    
    @Test func testAppendAndPrepend() {
        let deque = Deque<Int>()
        deque.append(1)
        #expect(deque.count == 1)
        #expect(deque.first == 1)
        #expect(deque.last == 1)
        #expect(deque.front === deque.back)
        
        deque.append(2)
        #expect(deque.count == 2)
        #expect(deque.first == 1)
        #expect(deque.last == 2)
        #expect(deque.front!.next === deque.back)
        #expect(deque.back!.prev === deque.front)
        
        deque.prepend(0)
        #expect(deque.count == 3)
        #expect(deque.first == 0)
        #expect(deque.last == 2)
        #expect(deque.front!.content == 0)
        #expect(deque.front!.next!.content == 1)
    }
    
    @Test func testRemoveFirst() {
        let deque = Deque([1, 2, 3])
        let removed = deque.removeFirst()
        #expect(removed == 1)
        #expect(deque.count == 2)
        #expect(deque.first == 2)
        #expect(deque.front!.prev == nil)
        #expect(deque.back!.content == 3)
    }
    
    @Test func testRemoveLast() {
        let deque = Deque([1, 2, 3])
        let removed = deque.removeLast()
        #expect(removed == 3)
        #expect(deque.count == 2)
        #expect(deque.last == 2)
        #expect(deque.back!.next == nil)
        #expect(deque.front!.content == 1)
    }
    
    @Test func testRemoveFromEmpty() {
        let deque = Deque<Int>()
        #expect(deque.removeFirst() == nil)
        #expect(deque.removeLast() == nil)
    }
    
    @Test func testRemoveNodeMiddle() {
        let deque = Deque([1, 2, 3, 4])
        let middle = deque.front!.next!      // node with content 2
        let removed = deque.remove(middle)
        #expect(removed == 2)
        #expect(deque.count == 3)
        #expect(deque.first == 1)
        #expect(deque.last == 4)
        // check links bypassed
        #expect(deque.front!.next!.content == 3)
        #expect(deque.front!.next === deque.back!.prev)
        // node cleaned
        #expect(middle.prev == nil)
        #expect(middle.next == nil)
    }
    
    @Test func testRemoveNodeAtEdges() {
        let deque = Deque([1, 2, 3])
        let firstNode = deque.front!
        let lastNode = deque.back!
        
        let removedFirst = deque.remove(firstNode)
        #expect(removedFirst == 1)
        #expect(deque.count == 2)
        #expect(deque.first == 2)
        #expect(firstNode.prev == nil && firstNode.next == nil)
        
        let removedLast = deque.remove(lastNode)
        #expect(removedLast == 3)
        #expect(deque.count == 1)
        #expect(deque.last == 2)
        #expect(lastNode.prev == nil && lastNode.next == nil)
    }
    
    @Test func testForEach() throws {
        let deque = Deque([10, 20, 30])
        var seen: [Int] = []
        deque.forEach { seen.append($0) }
        #expect(seen == [10, 20, 30])
        // forEach must not mutate
        #expect(deque.count == 3)
    }
    
    @Test func testIteratorProtocol() {
        let deque = Deque([1, 2, 3])
        var collected: [Int] = []
        while let v = deque.next() {
            collected.append(v)
        }
        // next() is alias for removeLast()
        #expect(collected == [3, 2, 1])
        #expect(deque.isEmpty)
    }
    
    @Test func testSequenceInitializer() {
        let seq = stride(from: 5, to: 8, by: 1)   // yields 5,6,7
        let deque = Deque(seq)
        #expect(deque.count == 3)
        #expect(deque.first == 5)
        #expect(deque.last == 7)
    }
    
    @Test func testArrayLiteralInitializer() {
        let deque: Deque = [42, 43, 44]
        #expect(deque.count == 3)
        #expect(deque.first == 42)
        #expect(deque.last == 44)
    }
    
    @Test func testDescription() {
        let empty: Deque<Int> = []
        #expect(empty.description == "[]")
        let deque: Deque = [1, 2, 3]
        #expect(deque.description == "[1, 2, 3]")
    }
    
    @Test func testArrayInitFromDeque() {
        let deque: Deque = [100, 200, 300]
        let array = Array(deque)
        #expect(array == [100, 200, 300])
        // original deque preserved
        #expect(deque.count == 3)
        #expect(deque.first == 100 && deque.last == 300)
    }

    @Test func testRemoveOnlyElement() {
        let deque = Deque([42])
        #expect(deque.count == 1)
        let removed = deque.remove(deque.front!)
        #expect(removed == 42)
        #expect(deque.isEmpty)
        #expect(deque.front == nil)
        #expect(deque.back == nil)
    }

    @Test func testStringElements() {
        let deque = Deque(["hello", "world"])
        #expect(deque.first == "hello")
        #expect(deque.last == "world")
        #expect(deque.removeFirst() == "hello")
        #expect(deque.removeLast() == "world")
        #expect(deque.isEmpty)
    }

    @Test func testInterleavedPrependAndRemoveLast() {
        let deque = Deque<Int>()
        deque.prepend(1)
        deque.prepend(0)
        deque.append(2)
        // [0, 1, 2]
        #expect(deque.removeLast() == 2)
        #expect(deque.removeFirst() == 0)
        #expect(deque.removeFirst() == 1)
        #expect(deque.isEmpty)
    }

    @Test func testLargeDequeDeinit() {
        // exercises iterative deinit — must not stack overflow
        let deque = Deque(0..<100_000)
        #expect(deque.count == 100_000)
        #expect(deque.first == 0)
        #expect(deque.last == 99_999)
    }

    @Test func testRemoveCleansNodeLinks() {
        let deque = Deque([1, 2, 3])
        let middle = deque.front!.next!
        deque.remove(middle)
        #expect(middle.prev == nil)
        #expect(middle.next == nil)
    }

    @Test func classPayloadAppendAndPrepend() {
        let deque = Deque<DequeTestObject>()
        let obj1 = DequeTestObject(id: 1)
        let obj2 = DequeTestObject(id: 2)
        let obj3 = DequeTestObject(id: 0)

        deque.append(obj1)
        deque.append(obj2)
        deque.prepend(obj3)

        #expect(deque.count == 3)
        #expect(deque.first?.id == 0)
        #expect(deque.last?.id == 2)
        #expect(deque.front!.content === obj3)
        #expect(deque.front!.next!.content === obj1)
    }

    @Test func classPayloadRemoveFirst() {
        let obj1 = DequeTestObject(id: 1)
        let obj2 = DequeTestObject(id: 2)
        let obj3 = DequeTestObject(id: 3)
        let deque = Deque([obj1, obj2, obj3])

        let removed = deque.removeFirst()
        #expect(removed === obj1)
        #expect(removed?.id == 1)
        #expect(deque.count == 2)
        #expect(deque.first?.id == 2)
    }

    @Test func classPayloadRemoveLast() {
        let obj1 = DequeTestObject(id: 1)
        let obj2 = DequeTestObject(id: 2)
        let obj3 = DequeTestObject(id: 3)
        let deque = Deque([obj1, obj2, obj3])

        let removed = deque.removeLast()
        #expect(removed === obj3)
        #expect(removed?.id == 3)
        #expect(deque.count == 2)
        #expect(deque.last?.id == 2)
    }

    @Test func classPayloadRemoveNode() {
        let obj1 = DequeTestObject(id: 1)
        let obj2 = DequeTestObject(id: 2)
        let obj3 = DequeTestObject(id: 3)
        let deque = Deque([obj1, obj2, obj3])

        let middle = deque.front!.next!
        let removed = deque.remove(middle)
        #expect(removed === obj2)
        #expect(removed.id == 2)
        #expect(deque.count == 2)
        #expect(middle.prev == nil)
        #expect(middle.next == nil)
    }

    @Test func classPayloadReferenceMutability() {
        let obj = DequeTestObject(id: 10, tag: "original")
        let deque = Deque([obj])

        obj.tag = "modified"

        #expect(deque.first?.tag == "modified")
        #expect(deque.first === obj)
    }

    @Test func classPayloadForEach() {
        let obj1 = DequeTestObject(id: 10)
        let obj2 = DequeTestObject(id: 20)
        let obj3 = DequeTestObject(id: 30)
        let deque = Deque([obj1, obj2, obj3])

        var seen: [Int] = []
        deque.forEach { seen.append($0.id) }
        #expect(seen == [10, 20, 30])
    }

}
