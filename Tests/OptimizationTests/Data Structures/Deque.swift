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


private enum TestError: Error, Equatable {
    case intentional
}


// MARK: - Basic Properties

@Suite
struct DequeBasicTests {

    @Test func empty() {
        let deque = Deque<Int>()
        #expect(deque.front == nil)
        #expect(deque.back == nil)
        #expect(deque.isEmpty)
        #expect(deque.count == 0)
        #expect(deque.first == nil)
        #expect(deque.last == nil)
    }

    @Test func countTracking() {
        let deque = Deque<Int>()
        #expect(deque.count == 0)

        deque.append(1)
        #expect(deque.count == 1)

        deque.prepend(0)
        #expect(deque.count == 2)

        _ = deque.removeFirst()
        #expect(deque.count == 1)

        _ = deque.removeLast()
        #expect(deque.count == 0)
    }

    @Test func isEmptyTracking() {
        let deque = Deque<Int>()
        #expect(deque.isEmpty)

        deque.append(1)
        #expect(!deque.isEmpty)

        _ = deque.removeFirst()
        #expect(deque.isEmpty)
    }

    @Test func frontAndBack() {
        let deque = Deque<Int>()
        #expect(deque.front == nil)
        #expect(deque.back == nil)

        deque.append(1)
        #expect(deque.front != nil)
        #expect(deque.back != nil)
        #expect(deque.front === deque.back)

        deque.append(2)
        #expect(deque.front !== deque.back)
        #expect(deque.front?.content == 1)
        #expect(deque.back?.content == 2)
    }

    @Test func firstAndLast() {
        let deque = Deque<Int>()
        #expect(deque.first == nil)
        #expect(deque.last == nil)

        deque.append(10)
        #expect(deque.first == 10)
        #expect(deque.last == 10)

        deque.append(20)
        #expect(deque.first == 10)
        #expect(deque.last == 20)

        deque.prepend(0)
        #expect(deque.first == 0)
        #expect(deque.last == 20)
    }

}


// MARK: - Append / Prepend

@Suite
struct DequeAppendPrependTests {

    @Test func appendAndPrepend() {
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

    @Test func appendToEmpty() {
        let deque = Deque<String>()
        deque.append("first")
        #expect(deque.count == 1)
        #expect(deque.first == "first")
        #expect(deque.last == "first")
        #expect(deque.front === deque.back)
    }

    @Test func prependToEmpty() {
        let deque = Deque<Double>()
        deque.prepend(3.14)
        #expect(deque.count == 1)
        #expect(deque.first == 3.14)
        #expect(deque.last == 3.14)
        #expect(deque.front === deque.back)
    }

    @Test func interleavedPrependAndRemoveLast() {
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

    @Test func appendPrependMany() {
        let deque = Deque<Int>()
        for i in 0..<500 {
            if i % 2 == 0 {
                deque.append(i)
            } else {
                deque.prepend(i)
            }
        }
        #expect(deque.count == 500)
    }

}


// MARK: - Remove Operations

@Suite
struct DequeRemoveTests {

    @Test func removeFirst() {
        let deque = Deque([1, 2, 3])
        let removed = deque.removeFirst()
        #expect(removed == 1)
        #expect(deque.count == 2)
        #expect(deque.first == 2)
        #expect(deque.front!.prev == nil)
        #expect(deque.back!.content == 3)
    }

    @Test func removeLast() {
        let deque = Deque([1, 2, 3])
        let removed = deque.removeLast()
        #expect(removed == 3)
        #expect(deque.count == 2)
        #expect(deque.last == 2)
        #expect(deque.back!.next == nil)
        #expect(deque.front!.content == 1)
    }

    @Test func removeFromEmpty() {
        let deque = Deque<Int>()
        #expect(deque.removeFirst() == nil)
        #expect(deque.removeLast() == nil)
    }

    @Test func removeOnlyElement() {
        let deque = Deque([42])
        #expect(deque.count == 1)
        let removed = deque.remove(deque.front!)
        #expect(removed == 42)
        #expect(deque.isEmpty)
        #expect(deque.front == nil)
        #expect(deque.back == nil)
    }

    @Test func removeOnlyElementViaRemoveFirst() {
        let deque = Deque([42])
        #expect(deque.removeFirst() == 42)
        #expect(deque.isEmpty)
        #expect(deque.front == nil)
        #expect(deque.back == nil)
    }

    @Test func removeOnlyElementViaRemoveLast() {
        let deque = Deque([99])
        #expect(deque.removeLast() == 99)
        #expect(deque.isEmpty)
        #expect(deque.front == nil)
        #expect(deque.back == nil)
    }

    @Test func removeNodeMiddle() {
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

    @Test func removeNodeAtEdges() {
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

    @Test func removeCleansNodeLinks() {
        let deque = Deque([1, 2, 3])
        let middle = deque.front!.next!
        deque.remove(middle)
        #expect(middle.prev == nil)
        #expect(middle.next == nil)
    }

    @Test func removeAllOneByOne() {
        let deque = Deque(0..<100)
        #expect(deque.count == 100)

        var count = 0
        while !deque.isEmpty {
            _ = deque.removeFirst()
            count += 1
        }
        #expect(count == 100)
        #expect(deque.front == nil)
        #expect(deque.back == nil)
    }

    @Test func removeAllOneByOneFromBack() {
        let deque = Deque(0..<100)
        var count = 0
        while deque.removeLast() != nil {
            count += 1
        }
        #expect(count == 100)
        #expect(deque.isEmpty)
    }

    @Test func interleavedRemoveFirstAndLast() {
        let deque = Deque([1, 2, 3, 4, 5, 6])
        #expect(deque.removeFirst() == 1)
        #expect(deque.removeLast() == 6)
        #expect(deque.removeFirst() == 2)
        #expect(deque.removeLast() == 5)
        #expect(deque.removeFirst() == 3)
        #expect(deque.removeLast() == 4)
        #expect(deque.isEmpty)
    }

}


// MARK: - Iteration

@Suite
struct DequeIterationTests {

    @Test func forEach() throws {
        let deque = Deque([10, 20, 30])
        var seen: [Int] = []
        deque.forEach { seen.append($0) }
        #expect(seen == [10, 20, 30])
        // forEach must not mutate
        #expect(deque.count == 3)
    }

    @Test func forEachEmpty() throws {
        let deque = Deque<Int>()
        var called = false
        deque.forEach { _ in called = true }
        #expect(!called)
    }

    @Test func forEachSingleElement() throws {
        let deque = Deque([42])
        var seen: [Int] = []
        deque.forEach { seen.append($0) }
        #expect(seen == [42])
        #expect(deque.count == 1)
    }

    @Test func forEachThrows() throws {
        let deque = Deque([1, 2, 3, 4, 5])
        var visited: [Int] = []

        #expect(throws: TestError.intentional) {
            try deque.forEach { value in
                visited.append(value)
                if value == 3 {
                    throw TestError.intentional
                }
            }
        }
        #expect(visited == [1, 2, 3])
        #expect(deque.count == 5)
    }

    @Test func iteratorProtocol() {
        let deque = Deque([1, 2, 3])
        var collected: [Int] = []
        while let v = deque.next() {
            collected.append(v)
        }
        // next() is alias for removeLast()
        #expect(collected == [3, 2, 1])
        #expect(deque.isEmpty)
    }

    @Test func nextOnEmpty() {
        let deque = Deque<Int>()
        #expect(deque.next() == nil)
    }

    @Test func nextAfterPartialRemoval() {
        let deque = Deque([1, 2, 3, 4])
        _ = deque.removeFirst()
        // remaining: [2, 3, 4]
        var collected: [Int] = []
        while let v = deque.next() {
            collected.append(v)
        }
        // next() uses removeLast() → LIFO
        #expect(collected == [4, 3, 2])
    }

}


// MARK: - Description

@Suite
struct DequeDescriptionTests {

    @Test func description() {
        let empty: Deque<Int> = []
        #expect(empty.description == "[]")
        let deque: Deque = [1, 2, 3]
        #expect(deque.description == "[1, 2, 3]")
    }

    @Test func descriptionSingleElement() {
        let deque: Deque = [42]
        #expect(deque.description == "[42]")
    }

    @Test func descriptionStringElements() {
        let deque: Deque = ["hello", "world"]
        #expect(deque.description == "[hello, world]")
    }

}


// MARK: - Initializers

@Suite
struct DequeInitializerTests {

    @Test func sequenceInitializer() {
        let seq = stride(from: 5, to: 8, by: 1)   // yields 5,6,7
        let deque = Deque(seq)
        #expect(deque.count == 3)
        #expect(deque.first == 5)
        #expect(deque.last == 7)
    }

    @Test func sequenceInitializerEmpty() {
        let deque = Deque(EmptyCollection<Int>())
        #expect(deque.isEmpty)
        #expect(deque.count == 0)
    }

    @Test func arrayLiteralInitializer() {
        let deque: Deque = [42, 43, 44]
        #expect(deque.count == 3)
        #expect(deque.first == 42)
        #expect(deque.last == 44)
    }

    @Test func arrayLiteralEmpty() {
        let deque: Deque<Int> = []
        #expect(deque.isEmpty)
        #expect(deque.count == 0)
    }

    @Test func arrayInitFromDeque() {
        let deque: Deque = [100, 200, 300]
        let array = Array(deque)
        #expect(array == [100, 200, 300])
        // original deque preserved
        #expect(deque.count == 3)
        #expect(deque.first == 100 && deque.last == 300)
    }

    @Test func arrayInitFromEmptyDeque() {
        let deque = Deque<Int>()
        let array = Array(deque)
        #expect(array == [])
        #expect(deque.isEmpty)
    }

}


// MARK: - Node Conformances

@Suite
struct DequeNodeTests {

    @Test func nodeEquatable() {
        let deque = Deque([10, 20, 30])
        let front = deque.front!
        let alsoFront = deque.front!
        let back = deque.back!

        #expect(front == alsoFront)
        #expect(front != back)
        #expect(front == front) // reflexive
    }

    @Test func nodeHashable() {
        let deque = Deque([10, 20])
        let node1 = deque.front!
        let node2 = deque.front!

        var hasher1 = Hasher()
        var hasher2 = Hasher()
        node1.hash(into: &hasher1)
        node2.hash(into: &hasher2)
        #expect(hasher1.finalize() == hasher2.finalize())
    }

    @Test func nodeDescription() {
        let deque = Deque([42])
        #expect(deque.front!.description == "42")
    }

    @Test func nodeDescriptionWithString() {
        let deque = Deque(["test"])
        #expect(deque.front!.description == "test")
    }

    @Test func nodePrevAndNextAfterAppend() {
        let deque = Deque<Int>()
        deque.append(1)
        deque.append(2)
        deque.append(3)

        let first = deque.front!
        let second = first.next!
        let third = second.next!

        #expect(first.prev == nil)
        #expect(first.next === second)
        #expect(second.prev === first)
        #expect(second.next === third)
        #expect(third.prev === second)
        #expect(third.next == nil)
    }

    @Test func nodePrevAndNextAfterPrepend() {
        let deque = Deque<Int>()
        deque.prepend(3)
        deque.prepend(2)
        deque.prepend(1)

        let first = deque.front!
        let second = first.next!
        let third = second.next!

        #expect(first.content == 1)
        #expect(second.content == 2)
        #expect(third.content == 3)
        #expect(first.prev == nil)
        #expect(third.next == nil)
    }

}


// MARK: - String Elements

@Suite
struct DequeStringElementTests {

    @Test func stringElements() {
        let deque = Deque(["hello", "world"])
        #expect(deque.first == "hello")
        #expect(deque.last == "world")
        #expect(deque.removeFirst() == "hello")
        #expect(deque.removeLast() == "world")
        #expect(deque.isEmpty)
    }

    @Test func stringAppendPrepend() {
        let deque = Deque<String>()
        deque.append("b")
        deque.prepend("a")
        deque.append("c")
        #expect(deque.first == "a")
        #expect(deque.last == "c")
        #expect(deque.removeFirst() == "a")
        #expect(deque.removeFirst() == "b")
        #expect(deque.removeFirst() == "c")
    }

    @Test func stringRemoveNode() {
        let deque = Deque(["apple", "banana", "cherry"])
        let middle = deque.front!.next!
        #expect(deque.remove(middle) == "banana")
        #expect(deque.count == 2)
        #expect(deque.first == "apple")
        #expect(deque.last == "cherry")
    }

}


// MARK: - Class Payload

@Suite
struct DequeClassPayloadTests {

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

    @Test func classPayloadNodeEquality() {
        let obj = DequeTestObject(id: 5)
        let deque = Deque([obj])
        let node = deque.front!

        let otherDeque = Deque([DequeTestObject(id: 5)])
        let otherNode = otherDeque.front!

        // Equal because content is equal (Equatable checks content, not identity)
        #expect(node == otherNode)
    }

}


// MARK: - Edge Cases

@Suite
struct DequeEdgeCaseTests {

    @Test func largeDequeDeinit() {
        // exercises iterative deinit — must not stack overflow
        let deque = Deque(0..<100_000)
        #expect(deque.count == 100_000)
        #expect(deque.first == 0)
        #expect(deque.last == 99_999)
    }

    @Test func removeAllAndReuse() {
        let deque = Deque<Int>()
        deque.append(1)
        deque.append(2)
        deque.append(3)
        _ = deque.removeFirst()
        _ = deque.removeFirst()
        _ = deque.removeFirst()
        #expect(deque.isEmpty)
        #expect(deque.front == nil)

        deque.append(4)
        #expect(deque.count == 1)
        #expect(deque.first == 4)
        #expect(deque.front === deque.back)
    }

    @Test func removeMiddleThenRemoveFirst() {
        let deque = Deque([1, 2, 3, 4, 5])
        let middle = deque.front!.next!.next! // node with 3
        deque.remove(middle)
        // [1, 2, 4, 5]
        #expect(deque.removeFirst() == 1)
        #expect(deque.removeFirst() == 2)
        #expect(deque.removeFirst() == 4)
        #expect(deque.removeFirst() == 5)
        #expect(deque.isEmpty)
    }

    @Test func removeMiddleThenRemoveLast() {
        let deque = Deque([1, 2, 3, 4, 5])
        let middle = deque.front!.next!.next! // node with 3
        deque.remove(middle)
        // [1, 2, 4, 5]
        #expect(deque.removeLast() == 5)
        #expect(deque.removeLast() == 4)
        #expect(deque.removeLast() == 2)
        #expect(deque.removeLast() == 1)
        #expect(deque.isEmpty)
    }

    @Test func appendAfterDraining() {
        let deque = Deque([1, 2, 3])
        while deque.removeFirst() != nil { }
        #expect(deque.isEmpty)

        deque.append(10)
        deque.append(20)
        #expect(deque.count == 2)
        #expect(deque.first == 10)
        #expect(deque.last == 20)
    }

    @Test func prependAfterDraining() {
        let deque = Deque([1, 2, 3])
        while deque.removeLast() != nil { }
        #expect(deque.isEmpty)

        deque.prepend(30)
        deque.prepend(20)
        deque.prepend(10)
        #expect(deque.count == 3)
        #expect(deque.first == 10)
        #expect(deque.last == 30)
    }

}
