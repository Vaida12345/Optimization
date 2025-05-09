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
        #expect(deque.firstIndex!.next == deque.lastIndex?.index)
        #expect(deque.lastIndex!.prev == deque.firstIndex?.index)
        
        deque.prepend(0)
        #expect(deque.count == 3)
        #expect(deque.first == 0)
        #expect(deque.last == 2)
        #expect(deque[deque.firstIndex!] == 0)
        #expect(deque[deque.index(after: deque.firstIndex!)!] == 1)
    }
    
    @Test func testRemoveFirst() {
        let deque = InlineDeque([1, 2, 3])
        let removed = deque.removeFirst()
        #expect(removed == 1)
        #expect(deque.count == 2)
        #expect(deque.first == 2)
        #expect(deque.firstIndex!.prev == nil)
        #expect(deque[deque.lastIndex!] == 3)
    }
    
    @Test func testRemoveLast() {
        let deque = InlineDeque([1, 2, 3])
        let removed = deque.removeLast()
        #expect(removed == 3)
        #expect(deque.count == 2)
        #expect(deque.last == 2)
        #expect(deque.lastIndex!.next == nil)
        #expect(deque[deque.firstIndex!] == 1)
    }
    
    @Test func testRemoveFromEmpty() {
        let deque = InlineDeque<Int>()
        #expect(deque.removeFirst() == nil)
        #expect(deque.removeLast() == nil)
    }
    
    @Test func testRemoveNodeMiddle() {
        let deque = InlineDeque([1, 2, 3, 4])
        let middle = deque.firstIndex!.next!      // node with content 2
        let removed = deque.remove(at: deque._index(at: middle))
        #expect(deque.description == "[1, 3, 4]")
        #expect(removed == 2)
        #expect(deque.count == 3)
        #expect(deque.first == 1)
        #expect(deque.last == 4)
        // check links bypassed
        #expect(deque[deque._index(at: deque.firstIndex!.next!)] == 3)
        #expect(deque.firstIndex!.next == deque.lastIndex!.prev)
    }
    
    @Test func testRemoveNodeAtEdges() {
        let deque = InlineDeque([1, 2, 3])
        let firstNode = deque.firstIndex!
        let lastNode = deque.lastIndex!
        
        let removedFirst = deque.remove(at: firstNode)
        #expect(removedFirst == 1)
        #expect(deque.count == 2)
        #expect(deque.first == 2)
        
        let removedLast = deque.remove(at: lastNode)
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
