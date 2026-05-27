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


private enum TestError: Error, Equatable {
    case intentional
    case withPayload(Int)
}


// MARK: - Basic Properties

@Suite
struct QueueBasicTests {

    @Test
    func initialization() throws {
        let queue: Queue<Int> = []
        #expect(queue.isEmpty)
        #expect(queue.count == 0)
    }

    @Test
    func emptyQueue() {
        let queue = Queue<Int>()
        #expect(queue.count == 0)
        #expect(queue.isEmpty)
        #expect(queue.dequeue() == nil)
        #expect(queue.next() == nil)
    }

    @Test
    func count() {
        let queue = Queue<Int>()
        #expect(queue.count == 0)

        queue.enqueue(1)
        #expect(queue.count == 1)

        queue.enqueue(2)
        #expect(queue.count == 2)

        _ = queue.dequeue()
        #expect(queue.count == 1)

        _ = queue.dequeue()
        #expect(queue.count == 0)
    }

    @Test
    func isEmptyTracking() {
        let queue = Queue<Int>()
        #expect(queue.isEmpty)

        queue.enqueue(1)
        #expect(!queue.isEmpty)

        _ = queue.dequeue()
        #expect(queue.isEmpty)

        queue.enqueue(2)
        queue.enqueue(3)
        #expect(!queue.isEmpty)

        _ = queue.dequeue()
        #expect(!queue.isEmpty)

        _ = queue.dequeue()
        #expect(queue.isEmpty)
    }

}


// MARK: - Enqueue / Dequeue

@Suite
struct QueueEnqueueDequeueTests {

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
    func dequeueFromEmpty() {
        let queue = Queue<Int>()
        #expect(queue.dequeue() == nil)
        #expect(queue.dequeue() == nil)

        queue.enqueue(10)
        #expect(queue.dequeue() == 10)
        #expect(queue.dequeue() == nil)
    }

    @Test
    func largeQueueDeinit() {
        // exercises iterative deinit — must not stack overflow
        let queue = Queue(0..<100_000)
        #expect(queue.count == 100_000)
    }

    @Test
    func fifoOrdering() {
        let queue = Queue<Int>()
        for i in 0..<100 {
            queue.enqueue(i)
        }
        #expect(queue.count == 100)

        for i in 0..<100 {
            #expect(queue.dequeue() == i)
        }
        #expect(queue.isEmpty)
    }

}


// MARK: - Sequence / IteratorProtocol

@Suite
struct QueueIteratorTests {

    @Test
    func iteratorProtocol() {
        let queue: Queue<Int> = [1, 2, 3]
        var collected: [Int] = []
        while let v = queue.next() {
            collected.append(v)
        }
        // next() is alias for dequeue(), which removes first (FIFO)
        #expect(collected == [1, 2, 3])
        #expect(queue.isEmpty)
    }

    @Test
    func nextOnEmpty() {
        let queue = Queue<Int>()
        #expect(queue.next() == nil)
        #expect(queue.next() == nil)
    }

    @Test
    func nextConsumesQueue() {
        let queue: Queue<Int> = [5, 10, 15, 20]
        var result: [Int] = []
        while let element = queue.next() {
            result.append(element)
        }
        #expect(result == [5, 10, 15, 20])
        #expect(queue.isEmpty)
    }

}


// MARK: - forEach

@Suite
struct QueueForEachTests {

    @Test
    func forEach() throws {
        let queue: Queue<Int> = [10, 20, 30]
        var seen: [Int] = []
        queue.forEach { seen.append($0) }
        #expect(seen == [10, 20, 30])
        #expect(queue.count == 3) // forEach must not mutate
    }

    @Test
    func forEachEmpty() throws {
        let queue = Queue<Int>()
        var called = false
        queue.forEach { _ in called = true }
        #expect(!called)
        #expect(queue.isEmpty)
    }

    @Test
    func forEachSingleElement() throws {
        let queue: Queue<Int> = [42]
        var seen: [Int] = []
        queue.forEach { seen.append($0) }
        #expect(seen == [42])
        #expect(queue.count == 1)
    }

    @Test
    func forEachThrows() throws {
        let queue: Queue<Int> = [1, 2, 3, 4, 5]
        var visited: [Int] = []

        #expect(throws: TestError.intentional) {
            try queue.forEach { value in
                visited.append(value)
                if value == 3 {
                    throw TestError.intentional
                }
            }
        }
        #expect(visited == [1, 2, 3])
        #expect(queue.count == 5) // Must not mutate
    }

}


// MARK: - Description

@Suite
struct QueueDescriptionTests {

    @Test
    func description() {
        let queue: Queue<Int> = [1, 2, 3]
        #expect(queue.count == 3)

        #expect(queue.description == "[1, 2, 3]")
        #expect(Array(queue) == [1, 2, 3])
    }

    @Test
    func descriptionEmpty() {
        let queue = Queue<Int>()
        #expect(queue.description == "[]")
    }

    @Test
    func descriptionSingleElement() {
        let queue: Queue<Int> = [99]
        #expect(queue.description == "[99]")
    }

}


// MARK: - Initializers

@Suite
struct QueueInitializerTests {

    @Test
    func arrayLiteralInitializer() {
        let queue: Queue<Int> = [42, 43, 44]
        #expect(queue.count == 3)
        #expect(queue.dequeue() == 42)
        #expect(queue.dequeue() == 43)
        #expect(queue.dequeue() == 44)
    }

    @Test
    func arrayLiteralEmpty() {
        let queue: Queue<Int> = []
        #expect(queue.isEmpty)
        #expect(queue.count == 0)
    }

    @Test
    func sequenceInitializer() {
        let seq = stride(from: 5, to: 8, by: 1)   // yields 5,6,7
        let queue = Queue(seq)
        #expect(queue.count == 3)
        #expect(queue.dequeue() == 5)
        #expect(queue.dequeue() == 6)
        #expect(queue.dequeue() == 7)
    }

    @Test
    func sequenceInitializerEmpty() {
        let queue = Queue(EmptyCollection<Int>())
        #expect(queue.isEmpty)
        #expect(queue.count == 0)
    }

    @Test
    func arrayInitFromQueue() {
        let queue: Queue<Int> = [100, 200, 300]
        let array = Array(queue)
        #expect(array == [100, 200, 300])
        // original queue preserved (borrowing)
        #expect(queue.count == 3)
        #expect(queue.dequeue() == 100)
    }

}


// MARK: - String Elements

@Suite
struct QueueStringElementTests {

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
    func stringDescription() {
        let queue: Queue<String> = ["apple", "banana", "cherry"]
        #expect(queue.description == "[apple, banana, cherry]")
    }

    @Test
    func stringInterleaved() {
        let queue = Queue<String>()
        queue.enqueue("a")
        #expect(queue.dequeue() == "a")
        queue.enqueue("b")
        queue.enqueue("c")
        #expect(queue.dequeue() == "b")
        queue.enqueue("d")
        #expect(queue.dequeue() == "c")
        #expect(queue.dequeue() == "d")
        #expect(queue.isEmpty)
    }

}


// MARK: - Class Payload

@Suite
struct QueueClassPayloadTests {

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

    @Test
    func classPayloadDequeueAllAndReuse() {
        let queue = Queue<QueueTestObject>()
        let obj1 = QueueTestObject(id: 1)
        let obj2 = QueueTestObject(id: 2)

        queue.enqueue(obj1)
        queue.enqueue(obj2)
        _ = queue.dequeue()
        _ = queue.dequeue()
        #expect(queue.isEmpty)

        let obj3 = QueueTestObject(id: 3)
        queue.enqueue(obj3)
        #expect(queue.count == 1)
        #expect(queue.dequeue() === obj3)
    }

}


// MARK: - Edge Cases

@Suite
struct QueueEdgeCaseTests {

    @Test
    func enqueueDequeueRepeated() {
        let queue = Queue<Int>()
        for i in 0..<1000 {
            queue.enqueue(i)
            #expect(queue.dequeue() == i)
            #expect(queue.isEmpty)
        }
    }

    @Test
    func enqueueManyThenDequeueAll() {
        let queue = Queue<Int>()
        for i in 0..<1000 {
            queue.enqueue(i)
        }
        #expect(queue.count == 1000)

        for i in 0..<1000 {
            #expect(queue.dequeue() == i)
        }
        #expect(queue.isEmpty)
        #expect(queue.dequeue() == nil)
    }

    @Test
    func nilAfterDequeueAll() {
        let queue = Queue<Int>()
        queue.enqueue(1)
        queue.enqueue(2)
        _ = queue.dequeue()
        _ = queue.dequeue()
        #expect(queue.dequeue() == nil)
        #expect(queue.next() == nil)
        #expect(queue.isEmpty)
    }

}
