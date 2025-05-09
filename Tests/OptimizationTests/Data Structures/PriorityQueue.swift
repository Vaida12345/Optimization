//
//  PriorityQueue.swift
//  Essentials
//
//  Created by Vaida on 12/1/24.
//

import Testing
@testable
import Essentials


@Suite
struct PriorityQueueTests {
    
    @Test(arguments: [PriorityQueue<Int, Double>.WeightOrder.ascending, .descending])
    func initialization(order: PriorityQueue<Int, Double>.WeightOrder) throws {
        let queue = PriorityQueue<Int, Double>(order)
        #expect(queue.isEmpty)
        #expect(queue.count == 0)
    }
    
    @Test
    func enqueueDescending() throws {
        var queue = PriorityQueue<Int, Int>(.descending)
        queue.enqueue(1, weight: 1)
        queue.enqueue(2)
        queue.enqueue(3, weight: \.self)
        #expect(queue.count == 3)
        
        #expect(queue.dequeue() == 3)
        #expect(queue.dequeue() == 2)
        #expect(queue.dequeue() == 1)
        #expect(queue.dequeue() == nil)
    }
    
    @Test
    func enqueueAscending() throws {
        var queue = PriorityQueue<Int, Int>(.ascending)
        queue.enqueue(1, weight: 1)
        queue.enqueue(2)
        queue.enqueue(3, weight: \.self)
        #expect(queue.count == 3)
        
        #expect(queue.dequeue() == 1)
        #expect(queue.next() == 2)
        
        var weight: Int = 0
        #expect(queue.dequeue(weight: &weight) == 3)
        #expect(weight == 3)
        #expect(queue.dequeue(weight: &weight) == nil)
        #expect(weight == 3)
    }
    
    @Test
    func description() {
        var queue = PriorityQueue<Int, Int>(.ascending)
        queue.enqueue(1, weight: 1)
        queue.enqueue(2)
        queue.enqueue(3, weight: \.self)
        
        #expect(queue.description == "[1, 2, 3]")
        #expect(queue.debugDescription == "[1<1>, 2<2>, 3<3>]")
        #expect(Array(queue) == [1, 2, 3])
    }
    
}
