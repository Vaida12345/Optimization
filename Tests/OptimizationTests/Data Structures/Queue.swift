//
//  Queue.swift
//  Essentials
//
//  Created by Vaida on 12/1/24.
//

import Testing
@testable
import Essentials


@Suite
struct QueueTests {
    
    @Test
    func initialization() throws {
        let queue: Queue<Int> = []
        #expect(queue.isEmpty)
        #expect(queue.count == 0)
    }
    
    @Test
    func enqueue() throws {
        var queue = Queue<Int>()
        queue.enqueue(1)
        queue.enqueue(2)
        queue.enqueue(3)
        #expect(queue.count == 3)
        
        #expect(queue.dequeue() == 1)
        #expect(queue.dequeue() == 2)
        #expect(queue.next() == 3)
        #expect(queue.next() == nil)
    }
    
    @Test
    func description() {
        let queue: Queue<Int> = [1, 2, 3]
        #expect(queue.count == 3)
        
        #expect(queue.description == "[1, 2, 3]")
        #expect(Array(queue) == [1, 2, 3])
    }
    
}
