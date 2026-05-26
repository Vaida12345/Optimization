//
//  PriorityQueue.swift
//  Essentials
//
//  Created by Vaida on 12/1/24.
//

import Testing
@testable
import Optimization


final class PQTestObject: Equatable, CustomStringConvertible {
    let id: Int
    let name: String

    init(id: Int, name: String = "") {
        self.id = id
        self.name = name
    }

    static func == (lhs: PQTestObject, rhs: PQTestObject) -> Bool { lhs.id == rhs.id }
    var description: String { "Obj(\(id), \(name))" }
}


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

    @Test
    func peek() {
        var queue = PriorityQueue<Int, Int>(.descending)
        #expect(queue.peek() == nil)

        queue.enqueue(42, weight: 10)
        let node = queue.peek()
        #expect(node?.content == 42)
        #expect(node?.weight == 10)
        #expect(queue.count == 1) // peek must not mutate
    }

    @Test
    func removeAll() {
        var queue = PriorityQueue<Int, Int>(.ascending)
        queue.enqueue(1, weight: 10)
        queue.enqueue(2, weight: 20)
        queue.enqueue(3, weight: 30)

        queue.removeAll()
        #expect(queue.isEmpty)
        #expect(queue.count == 0)
        #expect(queue.peek() == nil)
    }

    @Test
    func dequeueWeightOnEmpty() {
        var queue = PriorityQueue<Int, Int>(.ascending)
        var weight: Int = 99
        let result = queue.dequeue(weight: &weight)
        #expect(result == nil)
        #expect(weight == 99) // weight must be unchanged
    }

    @Test
    func sameWeightElements() {
        var queue = PriorityQueue<Int, Int>(.ascending)
        queue.enqueue(1, weight: 5)
        queue.enqueue(2, weight: 5)
        queue.enqueue(3, weight: 5)

        // all three must dequeue (order among equal weights is not guaranteed)
        let a = queue.dequeue()
        let b = queue.dequeue()
        let c = queue.dequeue()
        let results = [a, b, c].compactMap { $0 }
        #expect(results.count == 3)
        #expect(Set(results) == [1, 2, 3])
        #expect(queue.dequeue() == nil)
    }

    @Test
    func stringElements() {
        var queue = PriorityQueue<String, Int>(.ascending)
        queue.enqueue("apple", weight: 3)
        queue.enqueue("zebra", weight: 1)
        queue.enqueue("mango", weight: 2)

        #expect(queue.dequeue() == "zebra")
        #expect(queue.dequeue() == "mango")
        #expect(queue.dequeue() == "apple")
    }

    @Test
    func classPayloadEnqueueDequeue() {
        var queue = PriorityQueue<PQTestObject, Int>(.ascending)
        let obj1 = PQTestObject(id: 1, name: "one")
        let obj2 = PQTestObject(id: 2, name: "two")
        let obj3 = PQTestObject(id: 3, name: "three")

        queue.enqueue(obj1, weight: 30)
        queue.enqueue(obj2, weight: 10)
        queue.enqueue(obj3, weight: 20)

        #expect(queue.count == 3)
        #expect(queue.dequeue()?.id == 2) // weight 10
        #expect(queue.dequeue()?.id == 3) // weight 20
        #expect(queue.dequeue()?.id == 1) // weight 30
        #expect(queue.dequeue() == nil)
    }

    @Test
    func classPayloadReferenceIdentity() {
        var queue = PriorityQueue<PQTestObject, Int>(.descending)
        let obj = PQTestObject(id: 99, name: "test")
        queue.enqueue(obj, weight: 100)

        let peeked = queue.peek()
        #expect(peeked?.content === obj)
        #expect(peeked?.content.id == 99)
        #expect(queue.count == 1)
    }

    @Test
    func classPayloadSameWeight() {
        var queue = PriorityQueue<PQTestObject, Int>(.descending)
        let obj1 = PQTestObject(id: 1)
        let obj2 = PQTestObject(id: 2)
        let obj3 = PQTestObject(id: 3)

        queue.enqueue(obj1, weight: 5)
        queue.enqueue(obj2, weight: 5)
        queue.enqueue(obj3, weight: 5)

        let results = [queue.dequeue(), queue.dequeue(), queue.dequeue()].compactMap { $0?.id }
        #expect(results.count == 3)
        #expect(Set(results) == [1, 2, 3])
        #expect(queue.dequeue() == nil)
    }

    @Test
    func classPayloadDequeueWithWeight() {
        var queue = PriorityQueue<PQTestObject, Int>(.ascending)
        queue.enqueue(PQTestObject(id: 1), weight: 100)
        queue.enqueue(PQTestObject(id: 2), weight: 200)

        var weight: Int = 0
        let first = queue.dequeue(weight: &weight)
        #expect(first?.id == 1)
        #expect(weight == 100)

        let second = queue.dequeue(weight: &weight)
        #expect(second?.id == 2)
        #expect(weight == 200)
    }

}
