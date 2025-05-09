//
//  InlineDeque.swift
//  Optimization
//
//  Created by Vaida on 2025-05-09.
//

import Testing
@testable
import Optimization


@Suite
struct InlineDequeTests {
    
    @Test func testEmpty() {
        let deque = InlineDeque<Int>()
        #expect(deque.frontIndex == nil)
        #expect(deque.backIndex == nil)
        #expect(deque.isEmpty)
        #expect(deque.count == 0)
        #expect(deque.first == nil)
        #expect(deque.last == nil)
    }
    
    @Test func testAppendAndPrepend() {
        let deque = InlineDeque<Int>(capacity: 3)
        deque.append(1)
        #expect(deque.count == 1)
        #expect(deque.first == 1)
        #expect(deque.last == 1)
        #expect(deque.frontIndex == deque.backIndex)
        
        deque.append(2)
        #expect(deque.count == 2)
        #expect(deque.first == 1)
        #expect(deque.last == 2)
        #expect(deque.front!.next == deque.back?.index)
        #expect(deque.back!.prev == deque.front?.index)
        
        deque.prepend(0)
        #expect(deque.count == 3)
        #expect(deque.first == 0)
        #expect(deque.last == 2)
        #expect(deque.front!.content == 0)
        #expect(deque.node(after: deque.front!)?.content == 1)
    }
    
    @Test func testRemoveFirst() {
        let deque = InlineDeque([1, 2, 3])
        let removed = deque.removeFirst()
        #expect(removed == 1)
        #expect(deque.count == 2)
        #expect(deque.first == 2)
        #expect(deque.front!.prev == nil)
        #expect(deque.back!.content == 3)
    }
    
    @Test func testRemoveLast() {
        let deque = InlineDeque([1, 2, 3])
        let removed = deque.removeLast()
        #expect(removed == 3)
        #expect(deque.count == 2)
        #expect(deque.last == 2)
        #expect(deque.back!.next == nil)
        #expect(deque.front!.content == 1)
    }
    
    @Test func testRemoveFromEmpty() {
        let deque = InlineDeque<Int>()
        #expect(deque.removeFirst() == nil)
        #expect(deque.removeLast() == nil)
    }
    
    @Test func testRemoveNodeMiddle() {
        let deque = InlineDeque([1, 2, 3, 4])
        let middle = deque.front!.next!      // node with content 2
        let removed = deque.remove(deque.node(at: middle))
        #expect(deque.description == "[1, 3, 4]")
        #expect(removed == 2)
        #expect(deque.count == 3)
        #expect(deque.first == 1)
        #expect(deque.last == 4)
        // check links bypassed
        #expect(deque.node(at: deque.front!.next!).content == 3)
        #expect(deque.front!.next == deque.back!.prev)
    }
    
    @Test func testRemoveNodeAtEdges() {
        let deque = InlineDeque([1, 2, 3])
        let firstNode = deque.front!
        let lastNode = deque.back!
        
        let removedFirst = deque.remove(firstNode)
        #expect(removedFirst == 1)
        #expect(deque.count == 2)
        #expect(deque.first == 2)
        
        let removedLast = deque.remove(lastNode)
        #expect(removedLast == 3)
        #expect(deque.count == 1)
        #expect(deque.last == 2)
    }
    
    @Test func testForEach() throws {
        let deque = InlineDeque([10, 20, 30])
        var seen: [Int] = []
        deque.forEach { seen.append($0) }
        #expect(seen == [10, 20, 30])
        // forEach must not mutate
        #expect(deque.count == 3)
    }
    
    @Test func testIteratorProtocol() {
        let deque = InlineDeque([1, 2, 3])
        var collected: [Int] = []
        while let v = deque.next() {
            collected.append(v)
        }
        // next() is alias for removeLast()
        #expect(collected == [3, 2, 1])
        #expect(deque.isEmpty)
    }
    
    @Test func testArrayLiteralInitializer() {
        let deque: InlineDeque = [42, 43, 44]
        #expect(deque.count == 3)
        #expect(deque.first == 42)
        #expect(deque.last == 44)
    }
    
    @Test func testDescription() {
        let empty: InlineDeque<Int> = []
        #expect(empty.description == "[]")
        let deque: InlineDeque = [1, 2, 3]
        #expect(deque.description == "[1, 2, 3]")
    }
    
    @Test func testArrayInitFromDeque() {
        let deque: InlineDeque = [100, 200, 300]
        let array = Array(deque)
        #expect(array == [100, 200, 300])
        // original deque preserved
        #expect(deque.count == 3)
        #expect(deque.first == 100 && deque.last == 300)
    }
}
