//
//  Deque.swift
//  Optimization
//
//  Created by Vaida on 2025-05-09.
//

import Testing
@testable
import Optimization


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
}
