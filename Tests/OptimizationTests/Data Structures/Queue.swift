//
//  Queue.swift
//  Essentials
//
//  Created by Vaida on 12/1/24.
//

import Testing
@testable
import Optimization


final class QueueTestObject: Equatable, CustomStringConvertible {
    let id: Int
    var label: String

    init(id: Int, label: String = "") {
        self.id = id
        self.label = label
    }

    static func == (lhs: QueueTestObject, rhs: QueueTestObject) -> Bool { lhs.id == rhs.id && lhs.label == rhs.label }
    var description: String { "Obj(\(id))" }
}


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
        let queue = Queue<Int>()
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

    @Test
    func stringElements() {
        let queue = Queue<String>()
        queue.enqueue("hello")
        queue.enqueue("world")
        #expect(queue.count == 2)
        #expect(queue.dequeue() == "hello")
        #expect(queue.dequeue() == "world")
        #expect(queue.dequeue() == nil)
    }

    @Test
    func singleElement() {
        let queue = Queue<Int>()
        queue.enqueue(42)
        #expect(queue.count == 1)
        #expect(queue.dequeue() == 42)
        #expect(queue.isEmpty)
        #expect(queue.dequeue() == nil)
    }

    @Test
    func interleavedEnqueueDequeue() {
        let queue = Queue<Int>()
        queue.enqueue(1)
        queue.enqueue(2)
        #expect(queue.dequeue() == 1)
        queue.enqueue(3)
        #expect(queue.dequeue() == 2)
        queue.enqueue(4)
        #expect(queue.dequeue() == 3)
        #expect(queue.dequeue() == 4)
        #expect(queue.isEmpty)
    }

    @Test
    func largeQueueDeinit() {
        // exercises iterative deinit — must not stack overflow
        let queue = Queue(0..<100_000)
        #expect(queue.count == 100_000)
    }

    @Test
    func forEach() throws {
        let queue: Queue<Int> = [10, 20, 30]
        var seen: [Int] = []
        queue.forEach { seen.append($0) }
        #expect(seen == [10, 20, 30])
        #expect(queue.count == 3) // forEach must not mutate
    }

    @Test
    func classPayloadEnqueueDequeue() {
        let queue = Queue<QueueTestObject>()
        let obj1 = QueueTestObject(id: 1)
        let obj2 = QueueTestObject(id: 2)
        let obj3 = QueueTestObject(id: 3)

        queue.enqueue(obj1)
        queue.enqueue(obj2)
        queue.enqueue(obj3)

        #expect(queue.count == 3)
        #expect(queue.dequeue() === obj1)
        #expect(queue.dequeue() === obj2)
        #expect(queue.dequeue() === obj3)
        #expect(queue.dequeue() == nil)
    }

    @Test
    func classPayloadReferenceMutability() {
        let obj = QueueTestObject(id: 42, label: "before")
        let queue = Queue<QueueTestObject>()
        queue.enqueue(obj)

        obj.label = "after"

        #expect(queue.dequeue()?.label == "after")
    }

    @Test
    func classPayloadSingleElement() {
        let queue = Queue<QueueTestObject>()
        let obj = QueueTestObject(id: 99)
        queue.enqueue(obj)

        #expect(queue.count == 1)
        let dequeued = queue.dequeue()
        #expect(dequeued === obj)
        #expect(queue.isEmpty)
    }

    @Test
    func classPayloadForEach() {
        let obj1 = QueueTestObject(id: 10)
        let obj2 = QueueTestObject(id: 20)
        let obj3 = QueueTestObject(id: 30)
        let queue: Queue<QueueTestObject> = [obj1, obj2, obj3]

        var seen: [Int] = []
        queue.forEach { seen.append($0.id) }
        #expect(seen == [10, 20, 30])
        #expect(queue.count == 3)
    }

}
