//
//  InlineDeque.swift
//  Optimization
//
//  Created by Vaida on 2025-05-09.
//

import Testing
@testable
import Optimization
import os


final class IDTestObject: Equatable, CustomStringConvertible {
    let id: Int
    var value: Int

    init(id: Int, value: Int = 0) {
        self.id = id
        self.value = value
    }

    static func == (lhs: IDTestObject, rhs: IDTestObject) -> Bool { lhs.id == rhs.id && lhs.value == rhs.value }
    var description: String { "Obj(\(id):\(value))" }
}


private enum TestError: Error, Equatable {
    case intentional
}


/// Verifies the linked list integrity by walking from first to last.
private func verifyListIntegrity<T>(_ deque: InlineDeque<T>) -> Bool {
    guard let first = deque.firstIndex else {
        // empty deque: lastIndex must also be nil, count must be 0
        return deque.lastIndex == nil && deque._count == 0
    }
    guard let last = deque.lastIndex else { return false }

    // walk forward
    var forwardCount = 0
    var current: InlineDeque<T>.Index? = first
    var prev: InlineDeque<T>.Index? = nil
    while let node = current {
        // prev pointer must be consistent
        if node.pointee.prev != prev { return false }
        prev = node
        current = node.pointee.next
        forwardCount += 1
        if forwardCount > deque._count + 1 { return false } // cycle detected
    }
    if prev != last { return false }

    // walk backward
    var backwardCount = 0
    current = last
    var next: InlineDeque<T>.Index? = nil
    while let node = current {
        if node.pointee.next != next { return false }
        next = node
        current = node.pointee.prev
        backwardCount += 1
        if backwardCount > deque._count + 1 { return false }
    }

    return forwardCount == backwardCount && forwardCount == deque._count
}


// MARK: - Basic Properties

@Suite
struct InlineDequeBasicTests {

    @Test func empty() {
        let deque = InlineDeque<Int>(capacity: 8)
        #expect(deque.firstIndex == nil)
        #expect(deque.lastIndex == nil)
        #expect(deque.isEmpty)
        #expect(deque.count == 0)
        #expect(deque.first == nil)
        #expect(deque.last == nil)
    }

    @Test func countTracking() {
        let deque = InlineDeque<Int>(capacity: 8)
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
        let deque = InlineDeque<Int>(capacity: 8)
        #expect(deque.isEmpty)

        deque.append(1)
        #expect(!deque.isEmpty)

        _ = deque.removeFirst()
        #expect(deque.isEmpty)
    }

    @Test func firstIndexAndLastIndex() {
        let deque = InlineDeque<Int>(capacity: 8)
        #expect(deque.firstIndex == nil)
        #expect(deque.lastIndex == nil)

        deque.append(42)
        #expect(deque.firstIndex != nil)
        #expect(deque.lastIndex != nil)
        #expect(deque.firstIndex == deque.lastIndex)

        deque.append(43)
        #expect(deque.firstIndex != deque.lastIndex)
        #expect(deque.firstIndex!.pointee.next == deque.lastIndex)
        #expect(deque.lastIndex!.pointee.prev == deque.firstIndex)
    }

    @Test func firstAndLast() {
        let deque = InlineDeque<Int>(capacity: 8)
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

    @Test func storedProperty() {
        let deque = InlineDeque<Int>(capacity: 8)
        #expect(deque.stored == 0)

        deque.append(1)
        #expect(deque.stored == 1)

        deque.append(2)
        #expect(deque.stored == 2)

        _ = deque.removeFirst() // stored does NOT decrease
        #expect(deque.stored == 2)

        deque.append(3)
        #expect(deque.stored == 3)
    }

    @Test func emptyDeinit() {
        // must not crash when deallocating without ever adding
        let deque = InlineDeque<Int>(capacity: 8)
        #expect(deque.isEmpty)
        #expect(deque._firstIndex == nil)
    }

}


// MARK: - Append / Prepend

@Suite
struct InlineDequeAppendPrependTests {

    @Test func appendAndPrepend() {
        let deque = InlineDeque<Int>(capacity: 3)
        deque.append(1)
        #expect(deque.count == 1)
        #expect(deque.first == 1)
        #expect(deque.last == 1)
        #expect(deque.firstIndex == deque.lastIndex)

        deque.append(2)
        #expect(deque.count == 2)
        #expect(deque.first == 1)
        #expect(deque.last == 2)
        #expect(deque.firstIndex!.pointee.next == deque.lastIndex)
        #expect(deque.lastIndex!.pointee.prev == deque.firstIndex)

        deque.prepend(0)
        #expect(deque.count == 3)
        #expect(deque.first == 0)
        #expect(deque.last == 2)
        #expect(deque[deque.firstIndex!] == 0)
        #expect(deque[deque.index(after: deque.firstIndex!)!] == 1)
        #expect(verifyListIntegrity(deque))
    }

    @Test func appendToEmpty() {
        let deque = InlineDeque<String>(capacity: 4)
        deque.append("first")
        #expect(deque.count == 1)
        #expect(deque.first == "first")
        #expect(deque.last == "first")
        #expect(deque.firstIndex!.pointee.next == nil)
        #expect(deque.firstIndex!.pointee.prev == nil)
        #expect(verifyListIntegrity(deque))
    }

    @Test func prependToEmpty() {
        let deque = InlineDeque<Double>(capacity: 4)
        deque.prepend(3.14)
        #expect(deque.count == 1)
        #expect(deque.first == 3.14)
        #expect(deque.last == 3.14)
        #expect(deque.firstIndex!.pointee.next == nil)
        #expect(deque.firstIndex!.pointee.prev == nil)
        #expect(verifyListIntegrity(deque))
    }

    @Test func appendMultiple() {
        let deque = InlineDeque<Int>(capacity: 10)
        for i in 0..<10 {
            deque.append(i)
        }
        #expect(deque.count == 10)
        #expect(deque.first == 0)
        #expect(deque.last == 9)
        #expect(verifyListIntegrity(deque))
    }

    @Test func prependMultiple() {
        let deque = InlineDeque<Int>(capacity: 10)
        for i in (0..<10).reversed() {
            deque.prepend(i)
        }
        #expect(deque.count == 10)
        #expect(deque.first == 0)
        #expect(deque.last == 9)
        #expect(verifyListIntegrity(deque))
    }

    @Test func interleavedAppendPrepend() {
        let deque = InlineDeque<Int>(capacity: 10)
        deque.append(2)
        deque.prepend(0)
        deque.append(3)
        deque.prepend(-1)
        deque.append(4)
        deque.prepend(-2)
        // expected order: [-2, -1, 0, 2, 3, 4]
        var seen: [Int] = []
        var current = deque.firstIndex
        while let node = current {
            seen.append(deque[node])
            current = deque.index(after: node)
        }
        #expect(seen == [-2, -1, 0, 2, 3, 4])
        #expect(verifyListIntegrity(deque))
    }

}


// MARK: - Remove

@Suite
struct InlineDequeRemoveTests {

    @Test func removeFirst() {
        let deque = InlineDeque([1, 2, 3])
        let removed = deque.removeFirst()
        #expect(removed == 1)
        #expect(deque.count == 2)
        #expect(deque.first == 2)
        #expect(deque.firstIndex!.pointee.prev == nil)
        #expect(deque[deque.lastIndex!] == 3)
        #expect(verifyListIntegrity(deque))
    }

    @Test func removeLast() {
        let deque = InlineDeque([1, 2, 3])
        let removed = deque.removeLast()
        #expect(removed == 3)
        #expect(deque.count == 2)
        #expect(deque.last == 2)
        #expect(deque.lastIndex!.pointee.next == nil)
        #expect(deque[deque.firstIndex!] == 1)
        #expect(verifyListIntegrity(deque))
    }

    @Test func removeFromEmpty() {
        let deque = InlineDeque<Int>(capacity: 4)
        #expect(deque.removeFirst() == nil)
        #expect(deque.removeLast() == nil)
    }

    @Test func removeNodeMiddle() {
        let deque = InlineDeque([1, 2, 3, 4])

        let index1 = deque.firstIndex!
        let index2 = index1.pointee.next!
        let index3 = index2.pointee.next!
        let index4 = index3.pointee.next!

        #expect(index4 == deque.lastIndex)

        let middle = deque.firstIndex!.pointee.next!      // node with content 2
        let removed = deque.remove(at: middle)
        #expect(deque.description == "[1, 3, 4]")
        #expect(removed == 2)
        #expect(deque.count == 3)
        #expect(deque.first == 1)
        #expect(deque.last == 4)
        // check links bypassed
        #expect(deque[deque.firstIndex!.pointee.next!] == 3)
        #expect(deque.firstIndex!.pointee.next == deque.lastIndex!.pointee.prev)
        #expect(deque.index(before: index3) == index1)
        #expect(deque.index(after: index1) == index3)
        #expect(verifyListIntegrity(deque))
    }

    @Test func removeNodeAtEdges() {
        let deque = InlineDeque([1, 2, 3])
        let firstNode = deque.firstIndex!
        let lastNode = deque.lastIndex!

        let removedFirst = deque.remove(at: firstNode)
        #expect(removedFirst == 1)
        #expect(deque.count == 2)
        #expect(deque.first == 2)
        #expect(verifyListIntegrity(deque))

        let removedLast = deque.remove(at: lastNode)
        #expect(removedLast == 3)
        #expect(deque.count == 1)
        #expect(deque.last == 2)
        #expect(verifyListIntegrity(deque))
    }

    @Test func removeOnlyNode() {
        let deque = InlineDeque([42])
        let node = deque.firstIndex!
        let removed = deque.remove(at: node)
        #expect(removed == 42)
        #expect(deque.isEmpty)
        #expect(deque.firstIndex == nil)
        #expect(deque.lastIndex == nil)
    }

    @Test func removeOnlyNodeViaRemoveFirst() {
        let deque = InlineDeque([42])
        #expect(deque.removeFirst() == 42)
        #expect(deque.isEmpty)
        #expect(deque.firstIndex == nil)
        #expect(deque.lastIndex == nil)
    }

    @Test func removeOnlyNodeViaRemoveLast() {
        let deque = InlineDeque([99])
        #expect(deque.removeLast() == 99)
        #expect(deque.isEmpty)
        #expect(deque.firstIndex == nil)
        #expect(deque.lastIndex == nil)
    }

    @Test func removeAllOneByOneFromFront() {
        let deque = InlineDeque(Array(0..<100))
        #expect(deque.count == 100)
        for _ in 0..<100 {
            _ = deque.removeFirst()
        }
        #expect(deque.isEmpty)
        #expect(deque.firstIndex == nil)
        #expect(deque.lastIndex == nil)
    }

    @Test func removeAllOneByOneFromBack() {
        let deque = InlineDeque(Array(0..<100))
        for i in (0..<100).reversed() {
            #expect(deque.removeLast() == i)
        }
        #expect(deque.isEmpty)
    }

    @Test func removeAtClearsPointers() {
        let deque = InlineDeque([1, 2, 3, 4])
        guard let second = deque.firstIndex?.pointee.next else { return }

        // capture neighbors before removal
        let prev = second.pointee.prev
        let next = second.pointee.next

        deque.remove(at: second)

        // neighbors should now point to each other
        #expect(prev?.pointee.next == next)
        #expect(next?.pointee.prev == prev)
        #expect(deque.count == 3)
        #expect(verifyListIntegrity(deque))
    }

    @Test func removeFirstThenAppend() {
        // InlineDeque does not reclaim slots; need capacity for all-time peak
        let deque = InlineDeque<Int>(capacity: 10)
        for i in 1...5 { deque.append(i) }
        _ = deque.removeFirst()
        _ = deque.removeFirst()
        // remaining: [3, 4, 5]
        deque.append(6)
        deque.append(7)
        // [3, 4, 5, 6, 7]
        var seen: [Int] = []
        var current = deque.firstIndex
        while let node = current {
            seen.append(deque[node])
            current = deque.index(after: node)
        }
        #expect(seen == [3, 4, 5, 6, 7])
        #expect(verifyListIntegrity(deque))
    }

    @Test func removeAllThenAddAgain() {
        // InlineDeque does not reclaim slots; need capacity for all-time peak
        let deque = InlineDeque<Int>(capacity: 10)
        deque.append(1)
        deque.append(2)
        deque.append(3)
        _ = deque.removeFirst()
        _ = deque.removeFirst()
        _ = deque.removeFirst()
        #expect(deque.isEmpty)
        #expect(deque.count == 0)
        #expect(deque.first == nil)
        #expect(deque.last == nil)
        #expect(deque.firstIndex == nil)
        #expect(deque.lastIndex == nil)

        deque.append(10)
        deque.append(20)
        #expect(deque.count == 2)
        #expect(deque.first == 10)
        #expect(deque.last == 20)
        #expect(verifyListIntegrity(deque))
    }

}


// MARK: - Index Navigation

@Suite
struct InlineDequeNavigationTests {

    @Test func testIndexNavigation() {
        let deque = InlineDeque([1, 2, 3])
        guard let first = deque.firstIndex else { return }

        let second = deque.index(after: first)
        #expect(second != nil)
        #expect(deque[second!] == 2)

        let beforeSecond = deque.index(before: second!)
        #expect(beforeSecond == first)
    }

    @Test func indexAfterLast() {
        let deque = InlineDeque([1, 2, 3])
        guard let last = deque.lastIndex else { return }
        #expect(deque.index(after: last) == nil)
    }

    @Test func indexBeforeFirst() {
        let deque = InlineDeque([1, 2, 3])
        guard let first = deque.firstIndex else { return }
        #expect(deque.index(before: first) == nil)
    }

    @Test func walkForwardFullList() {
        let deque = InlineDeque(Array(0..<100))
        var current = deque.firstIndex
        var count = 0
        while let node = current {
            #expect(deque[node] == count)
            current = deque.index(after: node)
            count += 1
        }
        #expect(count == 100)
    }

    @Test func walkBackwardFullList() {
        let deque = InlineDeque(Array(0..<100))
        var current = deque.lastIndex
        var value = 99
        while let node = current {
            #expect(deque[node] == value)
            current = deque.index(before: node)
            value -= 1
        }
        #expect(value == -1)
    }

}


// MARK: - Update / Subscript

@Suite
struct InlineDequeMutationTests {

    @Test func update() {
        let deque = InlineDeque([10, 20, 30])
        guard let first = deque.firstIndex else { return }
        deque.update(at: first) { $0 += 5 }
        #expect(deque.first == 15)
    }

    @Test func updateThrows() {
        let deque = InlineDeque([1, 2, 3])
        guard let node = deque.firstIndex else { return }

        #expect(throws: TestError.intentional) {
            try deque.update(at: node) { value in
                if value == 1 {
                    throw TestError.intentional
                }
            }
        }
    }

    @Test func subscriptGetter() {
        let deque = InlineDeque([10, 20, 30])
        guard let first = deque.firstIndex else { return }
        #expect(deque[first] == 10)

        let last = deque.lastIndex!
        #expect(deque[last] == 30)
    }

    @Test func subscriptSetter() {
        let deque = InlineDeque([1, 2, 3])
        guard let middle = deque.firstIndex?.pointee.next else { return }
        deque[middle] = 99
        #expect(deque[middle] == 99)
        #expect(deque.first == 1)
        #expect(deque.last == 3)
    }

    @Test func subscriptSetFirst() {
        let deque = InlineDeque([1, 2, 3])
        guard let first = deque.firstIndex else { return }
        deque[first] = 100
        #expect(deque.first == 100)
        #expect(deque.last == 3)
    }

    @Test func subscriptSetLast() {
        let deque = InlineDeque([1, 2, 3])
        guard let last = deque.lastIndex else { return }
        deque[last] = 300
        #expect(deque.first == 1)
        #expect(deque.last == 300)
    }

}


// MARK: - forEach

@Suite
struct InlineDequeForEachTests {

    @Test func forEach() throws {
        let deque = InlineDeque([10, 20, 30])
        var seen: [Int] = []
        deque.forEach { seen.append($0) }
        #expect(seen == [10, 20, 30])
        // forEach must not mutate
        #expect(deque.count == 3)
    }

    @Test func forEachEmpty() throws {
        let deque = InlineDeque<Int>(capacity: 4)
        var called = false
        deque.forEach { _ in called = true }
        #expect(!called)
    }

    @Test func forEachSingle() throws {
        let deque = InlineDeque([42])
        var seen: [Int] = []
        deque.forEach { seen.append($0) }
        #expect(seen == [42])
        #expect(deque.count == 1)
    }

    @Test func forEachThrows() throws {
        let deque = InlineDeque([1, 2, 3, 4, 5])
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

    @Test func forEachAfterRemovals() throws {
        let deque = InlineDeque([1, 2, 3, 4, 5, 6])
        _ = deque.removeFirst()
        _ = deque.removeLast()
        _ = deque.remove(at: deque.firstIndex!.pointee.next!)
        // removed: 1, 6, and 3 (was at index after new first=2)
        // remaining: [2, 4, 5]
        var seen: [Int] = []
        deque.forEach { seen.append($0) }
        #expect(seen.count == 3)
        #expect(Set(seen) == [2, 4, 5])
    }

}


// MARK: - IteratorProtocol

@Suite
struct InlineDequeIteratorTests {

    @Test func iteratorProtocol() {
        let deque = InlineDeque([1, 2, 3])
        var collected: [Int] = []
        while let v = deque.next() {
            collected.append(v)
        }
        // next() is alias for removeLast()
        #expect(collected == [3, 2, 1])
        #expect(deque.isEmpty)
    }

    @Test func nextOnEmpty() {
        let deque = InlineDeque<Int>(capacity: 4)
        #expect(deque.next() == nil)
    }

    @Test func nextAfterPartialRemoval() {
        let deque = InlineDeque([1, 2, 3, 4])
        _ = deque.removeFirst()
        // remaining: [2, 3, 4]
        var collected: [Int] = []
        while let v = deque.next() {
            collected.append(v)
        }
        // next() = removeLast() → LIFO from remaining
        #expect(collected == [4, 3, 2])
    }

}


// MARK: - Description

@Suite
struct InlineDequeDescriptionTests {

    @Test func description() {
        let empty: InlineDeque<Int> = []
        #expect(empty.description == "[]")
        let deque: InlineDeque = [1, 2, 3]
        #expect(deque.description == "[1, 2, 3]")
    }

    @Test func descriptionSingle() {
        let deque: InlineDeque = [42]
        #expect(deque.description == "[42]")
    }

    @Test func descriptionAfterRemovals() {
        let deque = InlineDeque([1, 2, 3, 4, 5])
        _ = deque.removeFirst()
        _ = deque.removeLast()
        // [2, 3, 4]
        #expect(deque.description == "[2, 3, 4]")
    }

}


// MARK: - Initializers

@Suite
struct InlineDequeInitializerTests {

    @Test func capacityInit() {
        let deque = InlineDeque<Int>(capacity: 16)
        #expect(deque.isEmpty)
        #expect(deque.count == 0)
        #expect(deque.contents.count == 16)
    }

    @Test func collectionInit() {
        let deque = InlineDeque([100, 200, 300, 400])
        #expect(deque.count == 4)
        #expect(deque.first == 100)
        #expect(deque.last == 400)
        #expect(verifyListIntegrity(deque))
    }

    @Test func collectionInitEmpty() {
        let deque = InlineDeque(EmptyCollection<Int>())
        #expect(deque.isEmpty)
        #expect(deque.count == 0)
        #expect(deque.contents.count == 0)
    }

    @Test func collectionInitSingle() {
        let deque = InlineDeque([42])
        #expect(deque.count == 1)
        #expect(deque.first == 42)
        #expect(deque.last == 42)
    }

    @Test func arrayLiteralInit() {
        let deque: InlineDeque = [42, 43, 44]
        #expect(deque.count == 3)
        #expect(deque.first == 42)
        #expect(deque.last == 44)
    }

    @Test func arrayLiteralEmpty() {
        let deque: InlineDeque<Int> = []
        #expect(deque.isEmpty)
    }

    @Test func arrayInitFromDeque() {
        let deque: InlineDeque = [100, 200, 300]
        let array = Array(deque)
        #expect(array == [100, 200, 300])
        // original deque preserved
        #expect(deque.count == 3)
        #expect(deque.first == 100 && deque.last == 300)
    }

    @Test func arrayInitFromEmptyDeque() {
        let deque = InlineDeque<Int>(capacity: 4)
        #expect(Array(deque) == [])
    }

}


// MARK: - String Elements

@Suite
struct InlineDequeStringElementTests {

    @Test func stringElements() {
        let deque = InlineDeque(["alice", "bob", "charlie"])
        #expect(deque.first == "alice")
        #expect(deque.last == "charlie")
        #expect(deque.removeFirst() == "alice")
        #expect(deque.removeLast() == "charlie")
        #expect(deque.first == "bob")
        #expect(deque.removeFirst() == "bob")
        #expect(deque.isEmpty)
    }

    @Test func stringAppendPrepend() {
        let deque = InlineDeque<String>(capacity: 5)
        deque.append("b")
        deque.prepend("a")
        deque.append("c")
        #expect(deque.first == "a")
        #expect(deque.last == "c")
        #expect(verifyListIntegrity(deque))
    }

    @Test func stringSubscript() {
        let deque = InlineDeque(["hello", "world"])
        guard let first = deque.firstIndex else { return }
        deque[first] = "goodbye"
        #expect(deque.first == "goodbye")
        #expect(deque[first] == "goodbye")
    }

}


// MARK: - Class Payload

@Suite
struct InlineDequeClassPayloadTests {

    @Test func classPayloadAppendPrepend() {
        let deque = InlineDeque<IDTestObject>(capacity: 5)
        let obj1 = IDTestObject(id: 1)
        let obj2 = IDTestObject(id: 2)
        let obj3 = IDTestObject(id: 0)

        deque.append(obj1)
        deque.append(obj2)
        deque.prepend(obj3)

        #expect(deque.count == 3)
        #expect(deque.first?.id == 0)
        #expect(deque.last?.id == 2)
    }

    @Test func classPayloadRemoveAt() {
        let obj1 = IDTestObject(id: 1)
        let obj2 = IDTestObject(id: 2)
        let obj3 = IDTestObject(id: 3)
        let deque = InlineDeque([obj1, obj2, obj3])

        guard let middle = deque.firstIndex?.pointee.next else { return }
        let removed = deque.remove(at: middle)
        #expect(removed === obj2)
        #expect(removed.id == 2)
        #expect(deque.count == 2)
        #expect(deque.first?.id == 1)
        #expect(deque.last?.id == 3)
    }

    @Test func classPayloadUpdate() {
        let deque = InlineDeque([IDTestObject(id: 10, value: 0)])
        guard let first = deque.firstIndex else { return }

        deque.update(at: first) { $0.value += 5 }
        #expect(deque.first?.value == 5)
    }

    @Test func classPayloadSubscriptSetter() {
        let deque = InlineDeque([IDTestObject(id: 1), IDTestObject(id: 2)])
        guard let middle = deque.firstIndex?.pointee.next else { return }

        let newObj = IDTestObject(id: 99)
        deque[middle] = newObj
        #expect(deque[middle] === newObj)
        #expect(deque[middle].id == 99)
    }

    @Test func classPayloadReferenceMutability() {
        let obj = IDTestObject(id: 42, value: 10)
        let deque = InlineDeque([obj])

        obj.value = 999

        #expect(deque.first?.value == 999)
        #expect(deque.first === obj)
    }

    @Test func classPayloadForEach() {
        let obj1 = IDTestObject(id: 10)
        let obj2 = IDTestObject(id: 20)
        let obj3 = IDTestObject(id: 30)
        let deque = InlineDeque([obj1, obj2, obj3])

        var seen: [Int] = []
        deque.forEach { seen.append($0.id) }
        #expect(seen == [10, 20, 30])
    }

    @Test func classPayloadRemoveFirst() {
        let obj1 = IDTestObject(id: 1)
        let obj2 = IDTestObject(id: 2)
        let deque = InlineDeque([obj1, obj2])

        #expect(deque.removeFirst() === obj1)
        #expect(deque.count == 1)
        #expect(deque.first === obj2)
    }

    @Test func classPayloadRemoveLast() {
        let obj1 = IDTestObject(id: 1)
        let obj2 = IDTestObject(id: 2)
        let deque = InlineDeque([obj1, obj2])

        #expect(deque.removeLast() === obj2)
        #expect(deque.count == 1)
        #expect(deque.first === obj1)
    }

}


// MARK: - Large Data / Deinit

@Suite
struct InlineDequeLargeDataTests {

    @Test func largeAppend() {
        let sequence = Array(1...100_000)
        let deque = InlineDeque(sequence)
        #expect(deque.count == 100_000)
        #expect(deque.first == 1)
        #expect(deque.last == 100_000)
        #expect(verifyListIntegrity(deque))
    }

    @Test func largeDequeDeinit() {
        // exercises deinit walking the list and deinitializing each node
        let deque = InlineDeque(Array(0..<100_000))
        #expect(deque.count == 100_000)
        #expect(deque.first == 0)
        #expect(deque.last == 99_999)
    }

    @Test func largeAppendAndRemove() {
        let deque = InlineDeque(Array(0..<1000))
        for _ in 0..<500 {
            _ = deque.removeFirst()
            _ = deque.removeLast()
        }
        #expect(deque.isEmpty)
        #expect(deque.firstIndex == nil)
        #expect(deque.lastIndex == nil)
    }

}


// MARK: - Edge Cases

@Suite
struct InlineDequeEdgeCaseTests {

    @Test func singleElementListIntegrity() {
        let deque = InlineDeque([42])
        #expect(deque.firstIndex == deque.lastIndex)
        #expect(deque.firstIndex!.pointee.next == nil)
        #expect(deque.firstIndex!.pointee.prev == nil)
        #expect(verifyListIntegrity(deque))
    }

    @Test func twoElementListIntegrity() {
        let deque = InlineDeque([1, 2])
        #expect(deque.firstIndex!.pointee.next == deque.lastIndex)
        #expect(deque.lastIndex!.pointee.prev == deque.firstIndex)
        #expect(deque.firstIndex!.pointee.prev == nil)
        #expect(deque.lastIndex!.pointee.next == nil)
        #expect(verifyListIntegrity(deque))
    }

    @Test func listIntegrityAfterRemoveFirst() {
        let deque = InlineDeque([1, 2, 3, 4, 5])
        _ = deque.removeFirst()
        #expect(verifyListIntegrity(deque))
        _ = deque.removeFirst()
        #expect(verifyListIntegrity(deque))
    }

    @Test func listIntegrityAfterRemoveLast() {
        let deque = InlineDeque([1, 2, 3, 4, 5])
        _ = deque.removeLast()
        #expect(verifyListIntegrity(deque))
        _ = deque.removeLast()
        #expect(verifyListIntegrity(deque))
    }

    @Test func listIntegrityAfterRemoveMiddle() {
        let deque = InlineDeque([1, 2, 3, 4, 5])
        let middle = deque.firstIndex!.pointee.next!.pointee.next! // node with 3
        deque.remove(at: middle)
        #expect(verifyListIntegrity(deque))

        let newMiddle = deque.firstIndex!.pointee.next! // node with 2
        deque.remove(at: newMiddle)
        #expect(verifyListIntegrity(deque))
    }

    @Test func rebuildAfterFullDrain() {
        // InlineDeque does not reclaim slots; allocate enough for all-time peak
        let deque = InlineDeque<Int>(capacity: 25)
        for iteration in 0..<5 {
            for i in 0..<5 {
                deque.append(i + iteration * 10)
            }
            while !deque.isEmpty {
                _ = deque.removeFirst()
            }
            #expect(deque.firstIndex == nil)
            #expect(deque.lastIndex == nil)
            #expect(deque._count == 0)
        }
    }

    @Test func intMinMaxValues() {
        let deque = InlineDeque<Int>(capacity: 4)
        deque.append(Int.min)
        deque.append(0)
        deque.append(Int.max)
        #expect(deque.first == Int.min)
        #expect(deque.last == Int.max)
        #expect(deque.removeFirst() == Int.min)
        #expect(deque.removeFirst() == 0)
        #expect(deque.removeFirst() == Int.max)
    }

}
