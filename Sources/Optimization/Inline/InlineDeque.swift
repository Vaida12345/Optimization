//
//  InlineDeque.swift
//  Optimization
//
//  Created by Vaida on 2025-05-09.
//


/// First in, first out Queue where each note has both `prev` and `next`.
///
/// The main difference between ``InlineDeque`` and ``RingBuffer`` is that ``InlineDeque`` is able to remove elements at any index at O(*1*)
///
/// A queue operates considerably faster than an `Array` when both `enqueue(_:)` and `dequeue()` operations are required. If only `enqueue` is needed, using `Array.append` would outperform `enqueue` because `enqueue` involves individually allocating each node.
///
/// > Benchmark: Deque is faster on removal tests than arrays when the number of elements is greater than 400.
///
/// - Tip: This structure is preferred compared to ``Deque`` when you know the capacity in advance while requiring the two-directional node.
///
/// - Note: When an element is removed, its reference is removed, but not the allocation. The allocation for all elements is removed on `deinit`.
public final class InlineDeque<Element> {
    
    /// The underlying buffer.
    @usableFromInline
    internal let indexBuffer: UnsafeMutableBufferPointer<Index>
    
    @usableFromInline
    internal let buffer: UnsafeMutableBufferPointer<Element>
    
    
    /// The number of elements in the queue.
    ///
    /// - Complexity: O(*0*), stored property.
    public internal(set) var count: Int = 0
    
    /// The endIndex of the buffer
    private var stored: Int32 = 0
    
    
    @usableFromInline
    internal var frontIndex: Int32?
    @usableFromInline
    internal var backIndex: Int32?
    
    
    /// The first element stored
    @inlinable
    public var firstIndex: Index? {
        guard let frontIndex else { return nil }
        return self.indexBuffer[Int(frontIndex)]
    }
    
    /// The last element stored
    @inlinable
    public var lastIndex: Index? {
        guard let backIndex else { return nil }
        return self.indexBuffer[Int(backIndex)]
    }
    
    /// The first element stored
    @inlinable
    public var first: Element? {
        self.firstIndex.map({ self[$0] })
    }
    
    /// The last element stored
    @inlinable
    public var last: Element? {
        self.lastIndex.map({ self[$0] })
    }
    
    @inlinable
    public init(capacity: Int) {
        indexBuffer = .allocate(capacity: capacity)
        buffer = .allocate(capacity: capacity)
    }
    
    @inlinable
    deinit {
        self.indexBuffer.deallocate()
    }
    
    
    /// A two-directional Node
    public struct Index {
        
        @usableFromInline
        internal var index: Int32
        
        /// The node's predecessor.
        @usableFromInline
        internal var prev: Int32?
        
        /// The node's successor.
        @usableFromInline
        internal var next: Int32?
        
        
        @inlinable
        init(_ index: Int32) {
            self.index = index
        }
    }
    
    
    /// Returns whether the queue is empty.
    ///
    /// - Complexity: O(*1*)
    @inlinable
    public var isEmpty: Bool {
        frontIndex == nil && backIndex == nil
    }
    
    @inlinable
    public convenience init(_ sequence: some Collection<Element>) {
        self.init(capacity: sequence.count)
        
        for element in sequence {
            self.append(element)
        }
    }
    
    
    /// Append an element to the last.
    ///
    /// - Complexity: O(*1*)
    public func append(_ element: Element) {
        precondition(self.stored < self.indexBuffer.count, "append(_:) exceeds capacity")
        
        var node = Index(stored)
        
        if frontIndex == nil {
            self.frontIndex = 0
            self.backIndex = 0
        } else if let backIndex {
            self.indexBuffer[Int(backIndex)].next = stored
            node.prev = backIndex
            self.backIndex = stored
        } else {
            assertionFailure()
        }
        
        self.indexBuffer.initializeElement(at: Int(stored), to: node)
        self.buffer.initializeElement(at: Int(node.index), to: element)
        self.stored &+= 1
        self.count &+= 1
    }
    
    /// Append an element to the first.
    ///
    /// - Complexity: O(*1*)
    public func prepend(_ element: Element) {
        precondition(self.stored < self.indexBuffer.count, "prepend(_:) exceeds capacity")
        
        var node = Index(stored)
        
        if backIndex == nil {
            self.frontIndex = 0
            self.backIndex = 0
        } else if let frontIndex {
            self.indexBuffer[Int(frontIndex)].prev = stored
            node.next = frontIndex
            self.frontIndex = stored
        } else {
            assertionFailure()
        }
        
        self.indexBuffer.initializeElement(at: Int(stored), to: node)
        self.buffer.initializeElement(at: Int(node.index), to: element)
        self.stored &+= 1
        self.count &+= 1
    }
    
    
    /// Removes and returns the first element in the queue.
    ///
    /// On deque, the node is removed from the queue, along with the other nodes' links to it.
    ///
    /// - Complexity: O(*1*)
    public func removeFirst() -> Element? {
        guard let firstIndex = self.frontIndex else { return nil }
        let front = self.indexBuffer[Int(firstIndex)]
        
        if self.backIndex == firstIndex {
            self.frontIndex = nil
            self.backIndex = nil
        } else {
            self.frontIndex = front.next
            self.indexBuffer[Int(frontIndex!)].prev = nil
        }
        
        count &-= 1
        return self[front]
    }
    
    /// Removes and returns the last element in the queue.
    ///
    /// On deque, the node is removed from the queue, along with the other nodes' links to it.
    ///
    /// - Complexity: O(*1*)
    public func removeLast() -> Element? {
        guard let backIndex else { return nil }
        let back = self.indexBuffer[Int(backIndex)]
        
        if self.frontIndex == backIndex {
            self.frontIndex = nil
            self.backIndex = nil
        } else {
            self.backIndex = back.prev
            self.indexBuffer[Int(self.backIndex!)].next = nil
        }
        
        count &-= 1
        return self[back]
    }
    
    /// Removes the node from the parent deque by linking its `prev` and `next`.
    ///
    /// - Returns: The element that the node contains.
    ///
    /// - warning: It is the user's responsibility to ensure `self` owns `node`.
    ///
    /// - Complexity: O(*1*)
    @discardableResult
    public func remove(at index: Index) -> Element {
        if self.frontIndex == self.backIndex {
            self.frontIndex = nil
            self.backIndex = nil
        } else if frontIndex == index.index {
            self.frontIndex = self.indexBuffer[Int(frontIndex!)].next
            self.indexBuffer[Int(self.frontIndex!)].prev = nil
        } else if backIndex == index.index {
            self.backIndex = self.indexBuffer[Int(backIndex!)].prev
            self.indexBuffer[Int(self.backIndex!)].next = nil
        } else if let prev = index.prev,
                  let next = index.next {
            self.indexBuffer[Int(next)].prev = prev
            self.indexBuffer[Int(prev)].next = next
        }
        
        count &-= 1
        return self[index]
    }
    
    
    /// The successor of `node`.
    ///
    /// - Complexity: O(*1*)
    @inlinable
    public func index(after node: Index) -> Index? {
        // fetch the new node
        let node = self._index(at: node.index)
        guard let next = node.next else { return nil }
        return self.indexBuffer[Int(next)]
    }
    
    /// The predecessor of `node`.
    ///
    /// - Complexity: O(*1*)
    @inlinable
    public func index(before node: Index) -> Index? {
        // fetch the new node
        let node = self._index(at: node.index)
        guard let prev = node.prev else { return nil }
        return self.indexBuffer[Int(prev)]
    }
    
    /// Returns the node at the given index.
    ///
    /// - Complexity: O(*1*)
    @inlinable
    internal func _index(at _index: Int32) -> Index {
        self.indexBuffer[Int(_index)]
    }
    
    /// Updates the node at the given index.
    ///
    /// - Complexity: O(*1*)
    @inlinable
    public func update<E: Error>(at index: Index, block: (_ content: inout Element) throws(E) -> Void) throws(E) {
        try block(&self[index])
    }
    
    
    /// Iterate through the deque without removing any of its elements.
    @inlinable
    public func forEach<E: Error>(_ block: (_ element: Element) throws(E) -> Void) throws(E) {
        guard let frontIndex else { return }
        var current: Index? = self.indexBuffer[Int(frontIndex)]
        
        while let node = current {
            try block(self[node])
            current = self.index(after: node)
        }
    }
    
    
    @inlinable
    public subscript(_ index: Index) -> Element {
        get {
            self.buffer[Int(index.index)]
        }
        set {
            self.buffer[Int(index.index)] = newValue
        }
    }
    
}


extension InlineDeque: IteratorProtocol {
    
    /// Returns the next element in the queue.
    ///
    /// - Complexity: O(*1*), alias to ``removeLast()``.
    @inlinable
    public func next() -> Element? {
        self.removeLast()
    }
    
}

extension InlineDeque: CustomStringConvertible where Element: CustomStringConvertible {
    
    /// The description to the queue.
    @inlinable
    public var description: String {
        var description = "["
        
        self.forEach { element in
            description.write(element.description)
            description.write(", ")
        }
        
        if description.count != 1 {
            description.removeLast(2)
        }
        description += "]"
        return description
    }
}

extension InlineDeque: ExpressibleByArrayLiteral {
    
    @inlinable
    public convenience init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
    
}


extension InlineDeque.Index: Equatable where Element: Equatable {
    
    /// Equitable implementation.
    ///
    /// The equitable implementation never checks for address, to check address, use `===` instead.
    @inlinable
    public static func == (_ lhs: InlineDeque.Index, _ rhs: InlineDeque.Index) -> Bool {
        lhs.index == rhs.index
    }
    
}

extension InlineDeque.Index: CustomStringConvertible where Element: CustomStringConvertible {
    
    public var description: String {
        "Index(__underlyingNoncomparableIndex: \(index))"
    }
    
}


extension InlineDeque.Index: Hashable where Element: Hashable {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
    
}


extension Array {
    
    /// Initialize an array with a deque.
    ///
    /// - Parameters:
    ///   - deque: The source deque. Such deque borrowed to iterate.
    @inlinable
    public init(_ deque: borrowing InlineDeque<Element>) {
        self = []
        self.reserveCapacity(deque.count)
        
        deque.forEach { element in
            self.append(element)
        }
    }
    
}
