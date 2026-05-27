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


// MARK: - Basic Properties

@Suite
struct PriorityQueueBasicTests {

    @Test(arguments: [PriorityQueue<Int, Double>.WeightOrder.ascending, .descending])
    func initialization(order: PriorityQueue<Int, Double>.WeightOrder) throws {
        let queue = PriorityQueue<Int, Double>(order)
        #expect(queue.isEmpty)
        #expect(queue.count == 0)
    }

    @Test
    func countTracking() {
        var queue = PriorityQueue<Int, Int>(.ascending)
        #expect(queue.count == 0)

        queue.enqueue(1, weight: 10)
        #expect(queue.count == 1)

        queue.enqueue(2, weight: 20)
        #expect(queue.count == 2)

        _ = queue.dequeue()
        #expect(queue.count == 1)

        _ = queue.dequeue()
        #expect(queue.count == 0)
    }

    @Test
    func isEmptyTracking() {
        var queue = PriorityQueue<Int, Int>(.descending)
        #expect(queue.isEmpty)

        queue.enqueue(1, weight: 5)
        #expect(!queue.isEmpty)

        _ = queue.dequeue()
        #expect(queue.isEmpty)
    }

    @Test
    func weightOrderEnum() {
        #expect(PriorityQueue<Int, Int>.WeightOrder.ascending != .descending)
        #expect(PriorityQueue<Int, Int>.WeightOrder.ascending == .ascending)
    }

}


// MARK: - Enqueue

@Suite
struct PriorityQueueEnqueueTests {

    @Test
    func enqueueWithWeight() {
        var queue = PriorityQueue<Int, Double>(.ascending)
        queue.enqueue(1, weight: 3.0)
        queue.enqueue(2, weight: 1.0)
        queue.enqueue(3, weight: 2.0)

        #expect(queue.count == 3)
        #expect(queue.dequeue() == 2)  // weight 1.0
        #expect(queue.dequeue() == 3)  // weight 2.0
        #expect(queue.dequeue() == 1)  // weight 3.0
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
    func enqueueWithKeyPath() {
        var queue = PriorityQueue<String, Int>(.ascending)
        queue.enqueue("apple", weight: \.count)
        queue.enqueue("kiwi", weight: \.count)
        queue.enqueue("banana", weight: \.count)

        // "kiwi"(4), "apple"(5), "banana"(6) — ascending by string length
        #expect(queue.dequeue() == "kiwi")
        #expect(queue.dequeue() == "apple")
        #expect(queue.dequeue() == "banana")
    }

    @Test
    func enqueueWhereElementEqualsWeight() {
        var queue = PriorityQueue<Double, Double>(.ascending)
        queue.enqueue(3.14)
        queue.enqueue(1.0)
        queue.enqueue(2.71)

        #expect(queue.dequeue() == 1.0)
        #expect(queue.dequeue() == 2.71)
        #expect(queue.dequeue() == 3.14)
    }

    @Test
    func enqueueDuplicateWeights() {
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

}


// MARK: - Dequeue

@Suite
struct PriorityQueueDequeueTests {

    @Test
    func dequeueAscendingOrder() {
        var queue = PriorityQueue<Int, Int>(.ascending)
        queue.enqueue(10, weight: 100)
        queue.enqueue(20, weight: 50)
        queue.enqueue(30, weight: 75)

        #expect(queue.dequeue() == 20)  // weight 50
        #expect(queue.dequeue() == 30)  // weight 75
        #expect(queue.dequeue() == 10)  // weight 100
        #expect(queue.dequeue() == nil)
    }

    @Test
    func dequeueDescendingOrder() {
        var queue = PriorityQueue<Int, Int>(.descending)
        queue.enqueue(10, weight: 100)
        queue.enqueue(20, weight: 50)
        queue.enqueue(30, weight: 75)

        #expect(queue.dequeue() == 10)  // weight 100
        #expect(queue.dequeue() == 30)  // weight 75
        #expect(queue.dequeue() == 20)  // weight 50
        #expect(queue.dequeue() == nil)
    }

    @Test
    func dequeueWithWeight() {
        var queue = PriorityQueue<String, Double>(.ascending)
        queue.enqueue("low", weight: 1.0)
        queue.enqueue("high", weight: 100.0)

        var weight: Double = 0
        #expect(queue.dequeue(weight: &weight) == "low")
        #expect(weight == 1.0)

        #expect(queue.dequeue(weight: &weight) == "high")
        #expect(weight == 100.0)
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
    func dequeueFromEmpty() {
        var queue = PriorityQueue<String, Int>(.ascending)
        #expect(queue.dequeue() == nil)
        #expect(queue.next() == nil)
    }

    @Test
    func singleElementDequeue() {
        var queue = PriorityQueue<Int, Int>(.descending)
        queue.enqueue(42, weight: 10)
        #expect(queue.dequeue() == 42)
        #expect(queue.isEmpty)
    }

}


// MARK: - Peek

@Suite
struct PriorityQueuePeekTests {

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
    func peekAscending() {
        var queue = PriorityQueue<Int, Int>(.ascending)
        queue.enqueue(30, weight: 3)
        queue.enqueue(10, weight: 1)
        queue.enqueue(20, weight: 2)

        #expect(queue.peek()?.content == 10) // lowest weight
        #expect(queue.count == 3)
    }

    @Test
    func peekDescending() {
        var queue = PriorityQueue<Int, Int>(.descending)
        queue.enqueue(10, weight: 1)
        queue.enqueue(30, weight: 3)
        queue.enqueue(20, weight: 2)

        #expect(queue.peek()?.content == 30) // highest weight
        #expect(queue.count == 3)
    }

    @Test
    func peekDoesNotDequeue() {
        var queue = PriorityQueue<Int, Int>(.ascending)
        queue.enqueue(1, weight: 5)

        #expect(queue.peek()?.content == 1)
        #expect(queue.peek()?.content == 1)
        #expect(queue.count == 1)
        #expect(queue.dequeue() == 1)
        #expect(queue.peek() == nil)
    }

}


// MARK: - RemoveAll

@Suite
struct PriorityQueueRemoveAllTests {

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
    func removeAllThenReuse() {
        var queue = PriorityQueue<Int, Int>(.descending)
        queue.enqueue(1, weight: 10)
        queue.removeAll()
        #expect(queue.isEmpty)

        queue.enqueue(42, weight: 100)
        #expect(queue.count == 1)
        #expect(queue.peek()?.content == 42)
    }

}


// MARK: - IteratorProtocol / Sequence

@Suite
struct PriorityQueueIteratorTests {

    @Test
    func nextConsumesQueue() {
        var queue = PriorityQueue<Int, Int>(.ascending)
        queue.enqueue(3, weight: 30)
        queue.enqueue(1, weight: 10)
        queue.enqueue(2, weight: 20)

        var result: [Int] = []
        while let v = queue.next() {
            result.append(v)
        }
        #expect(result == [1, 2, 3])
        #expect(queue.isEmpty)
    }

    @Test
    func forInLoop() {
        var queue = PriorityQueue<Int, Int>(.descending)
        queue.enqueue(1, weight: 10)
        queue.enqueue(3, weight: 30)
        queue.enqueue(2, weight: 20)

        var result: [Int] = []
        for element in queue {
            result.append(element)
        }
        #expect(result == [3, 2, 1])
    }

    @Test
    func mapSequence() {
        var queue = PriorityQueue<Int, Int>(.ascending)
        queue.enqueue(1, weight: 10)
        queue.enqueue(2, weight: 20)
        queue.enqueue(3, weight: 30)

        let doubled = queue.map { $0 * 2 }
        #expect(doubled == [2, 4, 6])
    }

}


// MARK: - Description

@Suite
struct PriorityQueueDescriptionTests {

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
    func descriptionEmpty() {
        let queue = PriorityQueue<Int, Int>(.ascending)
        #expect(queue.description == "[]")
        #expect(queue.debugDescription == "[]")
    }

    @Test
    func debugDescription() {
        var queue = PriorityQueue<String, Double>(.descending)
        queue.enqueue("item", weight: 3.14)

        #expect(queue.debugDescription == "[item<3.14>]")
    }

}


// MARK: - Node

@Suite
struct PriorityQueueNodeTests {

    @Test
    func nodeComparison() {
        let node1 = PriorityQueue<Int, Int>.Node(1, weight: 10)
        let node2 = PriorityQueue<Int, Int>.Node(2, weight: 20)
        let node3 = PriorityQueue<Int, Int>.Node(3, weight: 10)

        #expect(node1 < node2)
        #expect(!(node2 < node1))
        #expect(node1 == node3)    // same weight
        #expect(node1 != node2)    // different weight
    }

    @Test
    func nodeProperties() {
        let node = PriorityQueue<String, Double>.Node("test", weight: 42.0)
        #expect(node.content == "test")
        #expect(node.weight == 42.0)
    }

}


// MARK: - String Elements

@Suite
struct PriorityQueueStringElementTests {

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
    func stringWithKeyPath() {
        var queue = PriorityQueue<String, Int>(.descending)
        queue.enqueue("a", weight: \.count)
        queue.enqueue("bbb", weight: \.count)
        queue.enqueue("cc", weight: \.count)

        // descending by string length: "bbb"(3), "cc"(2), "a"(1)
        #expect(queue.dequeue() == "bbb")
        #expect(queue.dequeue() == "cc")
        #expect(queue.dequeue() == "a")
    }

}


// MARK: - Class Payload

@Suite
struct PriorityQueueClassPayloadTests {

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

    @Test
    func classPayloadForEach() {
        var queue = PriorityQueue<PQTestObject, Int>(.ascending)
        queue.enqueue(PQTestObject(id: 30), weight: 3)
        queue.enqueue(PQTestObject(id: 10), weight: 1)
        queue.enqueue(PQTestObject(id: 20), weight: 2)

        var ids: [Int] = []
        for element in queue {
            ids.append(element.id)
        }
        #expect(ids == [10, 20, 30])
    }

}


// MARK: - Edge Cases

@Suite
struct PriorityQueueEdgeCaseTests {

    @Test
    func largeQueue() {
        var queue = PriorityQueue<Int, Int>(.ascending)
        for i in (0..<1000).reversed() {
            queue.enqueue(i, weight: i)
        }
        #expect(queue.count == 1000)

        for i in 0..<1000 {
            #expect(queue.dequeue() == i)
        }
        #expect(queue.isEmpty)
    }

    @Test
    func interleavedEnqueueDequeue() {
        var queue = PriorityQueue<Int, Int>(.ascending)
        queue.enqueue(3, weight: 3)
        queue.enqueue(1, weight: 1)
        #expect(queue.dequeue() == 1)

        queue.enqueue(2, weight: 2)
        queue.enqueue(4, weight: 4)
        #expect(queue.dequeue() == 2)
        #expect(queue.dequeue() == 3)
        #expect(queue.dequeue() == 4)
        #expect(queue.isEmpty)
    }

    @Test
    func negativeWeights() {
        var queue = PriorityQueue<Int, Int>(.ascending)
        queue.enqueue(1, weight: -5)
        queue.enqueue(2, weight: 0)
        queue.enqueue(3, weight: 10)

        #expect(queue.dequeue() == 1)  // weight -5
        #expect(queue.dequeue() == 2)  // weight 0
        #expect(queue.dequeue() == 3)  // weight 10
    }

    @Test
    func floatWeights() {
        var queue = PriorityQueue<Int, Double>(.ascending)
        queue.enqueue(2, weight: Double.infinity)
        queue.enqueue(1, weight: -Double.infinity)
        queue.enqueue(3, weight: 0)

        #expect(queue.dequeue() == 1)  // -inf
        #expect(queue.dequeue() == 3)  // 0
        #expect(queue.dequeue() == 2)  // +inf
    }

}
