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
/// > Benchmark: `InlineDeque` is faster on removal tests than arrays on any significant size.
///
/// - Tip: This structure is preferred compared to ``Deque`` when you know the capacity in advance while requiring the two-directional node.
///
/// - Note: When an element is removed, its reference is removed, but not the allocation. The allocation for all elements is removed on `deinit`.
public final class InlineDeque<Element> {
    
    /// The underlying buffer.
    @usableFromInline
    @exclusivity(unchecked)
    internal let contents: UnsafeMutableBufferPointer<Node>
    
    @exclusivity(unchecked)
    @usableFromInline
    var _count: Int = 0
    
    /// The number of elements in the queue.
    ///
    /// - Complexity: O(*0*), stored property.
    @inlinable
    public var count: Int {
        self._count
    }
    
    
    /// The endIndex of the buffer
    @exclusivity(unchecked)
    @usableFromInline
    var stored: Int = 0
    
    
    @exclusivity(unchecked)
    @usableFromInline
    var _firstIndex: Index?
    
    @exclusivity(unchecked)
    @usableFromInline
    var _lastIndex: Index?
    
    /// The first element stored
    @inlinable
    public var firstIndex: Index? { _firstIndex }
    
    /// The last element stored
    @inlinable
    public var lastIndex: Index? { _lastIndex }
    
    
    /// The first element stored
    @inlinable
    public var first: Element? {
        self._firstIndex.map({ self[$0] })
    }
    
    /// The last element stored
    @inlinable
    public var last: Element? {
        self._lastIndex.map({ self[$0] })
    }
    
    
    @inlinable
    public init(capacity: Int) {
        self.contents = .allocate(capacity: capacity)
    }
    
    @inlinable
    deinit {
        self.contents.deallocate()
    }
    
    
    /// A two-directional Node
    public struct Node {
        
        @usableFromInline
        internal var content: Element
        
        /// The node's predecessor.
        @usableFromInline
        internal var prev: UnsafeMutablePointer<Node>?
        
        /// The node's successor.
        @usableFromInline
        internal var next: UnsafeMutablePointer<Node>?
        
        
        @inlinable
        init(_ content: Element) {
            self.content = content
        }
    }
    
    public typealias Index = UnsafeMutablePointer<Node>
    
    
    /// Returns whether the queue is empty.
    ///
    /// - Complexity: O(*1*)
    @inlinable
    public var isEmpty: Bool {
        _firstIndex == nil
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
    @inlinable
    public func append(_ element: Element) {
        precondition(self.stored < self.contents.count, "append(_:) exceeds capacity")
        
        let node = Node(element)
        let pointer = self.contents.baseAddress! + self.stored
        pointer.initialize(to: node)
        
        if _firstIndex == nil {
            self._firstIndex = pointer
            self._lastIndex = pointer
        } else if let _lastIndex {
            _lastIndex.pointee.next = pointer
            pointer.pointee.prev = _lastIndex
            self._lastIndex = pointer
        }
        
        self.stored &+= 1
        self._count &+= 1
    }
    
    /// Append an element to the first.
    ///
    /// - Complexity: O(*1*)
    @inlinable
    public func prepend(_ element: Element) {
        precondition(self.stored < self.contents.count, "prepend(_:) exceeds capacity")
        
        let node = Node(element)
        let pointer = self.contents.baseAddress! + self.stored
        pointer.initialize(to: node)
        
        if _lastIndex == nil {
            self._firstIndex = pointer
            self._lastIndex = pointer
        } else if let _firstIndex {
            _firstIndex.pointee.prev = pointer
            pointer.pointee.next = _firstIndex
            self._firstIndex = pointer
        }
        
        self.stored &+= 1
        self._count &+= 1
    }
    
    
    /// Removes and returns the first element in the queue.
    ///
    /// On deque, the node is removed from the queue, along with the other nodes' links to it.
    ///
    /// - Complexity: O(*1*)
    @inlinable
    public func removeFirst() -> Element? {
        guard let _firstIndex else { return nil }
        let value = _firstIndex.pointee.content
        
        if self._lastIndex == _firstIndex {
            self._firstIndex = nil
            self._lastIndex = nil
        } else {
            self._firstIndex = _firstIndex.pointee.next
            self._firstIndex?.pointee.prev = nil
        }
        
        _count &-= 1
        return value
    }
    
    /// Removes and returns the last element in the queue.
    ///
    /// On deque, the node is removed from the queue, along with the other nodes' links to it.
    ///
    /// - Complexity: O(*1*)
    @inlinable
    public func removeLast() -> Element? {
        guard let _lastIndex else { return nil }
        let value = _lastIndex.pointee.content
        
        if self._firstIndex == _lastIndex {
            self._firstIndex = nil
            self._lastIndex = nil
        } else {
            self._lastIndex = _lastIndex.pointee.prev
            self._lastIndex?.pointee.next = nil
        }
        
        _count &-= 1
        return value
    }
    
    /// Removes the node from the parent deque by linking its `prev` and `next`.
    ///
    /// - Returns: The element that the node contains.
    ///
    /// - warning: It is the user's responsibility to ensure `self` owns `node`.
    ///
    /// - Complexity: O(*1*)
    @discardableResult
    @inlinable
    public func remove(at index: Index) -> Element {
        let value = index.pointee.content
        
        // fetch the new node
        if self._firstIndex == self._lastIndex {
            assert(index == _firstIndex)
            self._firstIndex = nil
            self._lastIndex = nil
        } else if _firstIndex == index {
            self._firstIndex = _firstIndex?.pointee.next
            self._firstIndex?.pointee.prev = nil
        } else if _lastIndex == index {
            self._lastIndex = _lastIndex?.pointee.prev
            self._lastIndex?.pointee.next = nil
        } else if let prev = index.pointee.prev,
                  let next = index.pointee.next {
            next.pointee.prev = prev
            prev.pointee.next = next
        }
        
        _count &-= 1
        return value
    }
    
    
    /// The successor of `node`.
    ///
    /// - Complexity: O(*1*)
    @inlinable
    public func index(after node: Index) -> Index? {
        node.pointee.next
    }
    
    /// The predecessor of `node`.
    ///
    /// - Complexity: O(*1*)
    @inlinable
    public func index(before node: Index) -> Index? {
        node.pointee.prev
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
        var current: Index? = self._firstIndex
        
        while let node = current {
            try block(self[node])
            current = self.index(after: node)
        }
    }
    
    
    /// - Complexity: O(*1*)
    @inlinable
    public subscript(_ index: Index) -> Element {
        get {
            index.pointee.content
        }
        set {
            index.pointee.content = newValue
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


extension Array {
    
    /// Initialize an array with a deque.
    ///
    /// - Parameters:
    ///   - deque: The source deque. Such deque borrowed to iterate.
    @inlinable
    public init(_ deque: borrowing InlineDeque<Element>) {
        self = []
        self.reserveCapacity(deque._count)
        
        deque.forEach { element in
            self.append(element)
        }
    }
    
}
