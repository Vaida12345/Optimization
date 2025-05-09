//
//  InlineDeque.swift
//  Optimization
//
//  Created by Vaida on 2025-05-09.
//


/// First in, first out Queue where each note has both `prev` and `next`.
///
/// A queue operates considerably faster than an `Array` when both ``enqueue(_:)`` and ``dequeue()`` operations are required. If only `enqueue` is needed, using `Array.append` would outperform `enqueue` because `enqueue` involves individually allocating each node.
/// 
/// > Benchmark: Deque is faster on removal tests than arrays when the number of elements is greater than 800.
public final class InlineDeque<Element> {
    
    /// The underlying buffer.
    private let buffer: UnsafeMutableBufferPointer<Node>
    
    /// The number of elements in the queue.
    ///
    /// - Complexity: O(*0*), stored property.
    public private(set) var count: Int
    /// The endIndex of the buffer
    private var stored: Int32 = 0
    
    
    public private(set) var frontIndex: Int32?
    public private(set) var backIndex: Int32?
    
    
    /// The first element stored
    public var front: Node? {
        guard let frontIndex else { return nil }
        return self.buffer[Int(frontIndex)]
    }
    
    /// The last element stored
    public var back: Node? {
        guard let backIndex else { return nil }
        return self.buffer[Int(backIndex)]
    }
    
    /// The first element stored
    public var first: Element? {
        self.front?.content
    }
    
    /// The last element stored
    public var last: Element? {
        self.back?.content
    }
    
    
    public init(capacity: Int) {
        buffer = .allocate(capacity: capacity)
        self.count = 0
    }
    
    deinit {
        self.buffer.deallocate()
    }
    
    
    /// A two-directional Node
    public struct Node {
        
        /// The content contained in the node
        public let content: Element
        
        internal var index: Int32
        
        /// The node's predecessor.
        internal var prev: Int32?
        
        /// The node's successor.
        internal var next: Int32?
        
        
        init(_ content: Element, index: Int32) {
            self.content = content
            self.index = index
        }
    }
    
    
    /// Returns whether the queue is empty.
    ///
    /// - Complexity: O(*1*)
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
        precondition(self.stored < self.buffer.count, "append(_:) exceeds capacity")
        
        var node = Node(element, index: stored)
        
        if frontIndex == nil {
            self.frontIndex = 0
            self.backIndex = 0
        } else if let backIndex {
            self.buffer[Int(backIndex)].next = stored
            node.prev = backIndex
            self.backIndex = stored
        } else {
            assertionFailure()
        }
        
        self.buffer.initializeElement(at: Int(stored), to: node)
        self.stored &+= 1
        self.count &+= 1
    }
    
    /// Append an element to the first.
    ///
    /// - Complexity: O(*1*)
    public func prepend(_ element: Element) {
        precondition(self.stored < self.buffer.count, "prepend(_:) exceeds capacity")
        
        var node = Node(element, index: stored)
        
        if backIndex == nil {
            self.frontIndex = 0
            self.backIndex = 0
        } else if let frontIndex {
            self.buffer[Int(frontIndex)].prev = stored
            node.next = frontIndex
            self.frontIndex = stored
        } else {
            assertionFailure()
        }
        
        self.buffer.initializeElement(at: Int(stored), to: node)
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
        let front = self.buffer[Int(firstIndex)]
        
        if self.backIndex == firstIndex {
            self.frontIndex = nil
            self.backIndex = nil
        } else {
            self.frontIndex = front.next
            self.buffer[Int(frontIndex!)].prev = nil
        }
        
        count &-= 1
        return front.content
    }
    
    /// Removes and returns the last element in the queue.
    ///
    /// On deque, the node is removed from the queue, along with the other nodes' links to it.
    ///
    /// - Complexity: O(*1*)
    public func removeLast() -> Element? {
        guard let backIndex else { return nil }
        let back = self.buffer[Int(backIndex)]
        
        if self.frontIndex == backIndex {
            self.frontIndex = nil
            self.backIndex = nil
        } else {
            self.backIndex = back.prev
            self.buffer[Int(self.backIndex!)].next = nil
        }
        
        count &-= 1
        return back.content
    }
    
    /// Removes the node from the parent deque by linking its ``Node/prev`` and ``Node/next``.
    ///
    /// - Returns: The element that the node contains.
    ///
    /// - warning: It is the user's responsibility to ensure `self` owns `node`.
    ///
    /// > Side Effect: This method also *cleans* `node` by removing its ``Node/prev`` and ``Node/next``.
    ///
    /// - Complexity: O(*1*)
    @discardableResult
    public func remove(_ node: Node) -> Element {
        if self.frontIndex == self.backIndex {
            self.frontIndex = nil
            self.backIndex = nil
        } else if frontIndex == node.index {
            self.frontIndex = self.buffer[Int(frontIndex!)].next
        } else if backIndex == node.index {
            self.backIndex = self.buffer[Int(backIndex!)].prev
        } else if let prev = node.prev,
                  let next = node.next {
            self.buffer[Int(next)].prev = prev
            self.buffer[Int(prev)].next = next
        }
        
        count &-= 1
        return node.content
    }
    
    
    /// The successor of `node`.
    public func node(after node: Node) -> Node? {
        guard let next = node.next else { return nil }
        return self.buffer[Int(next)]
    }
    
    /// The predecessor of `node`.
    public func node(before node: Node) -> Node? {
        guard let prev = node.prev else { return nil }
        return self.buffer[Int(prev)]
    }
    
    public func node(at index: Int32) -> Node {
        self.buffer[Int(index)]
    }
    
    
    /// Iterate through the deque without removing any of its elements.
    public func forEach<E: Error>(_ block: (_ element: Element) throws(E) -> Void) throws(E) {
        guard let frontIndex else { return }
        var current: Node? = self.buffer[Int(frontIndex)]
        
        while let node = current {
            try block(node.content)
            current = self.node(after: node)
        }
    }
    
}


extension InlineDeque: IteratorProtocol {
    
    /// Returns the next element in the queue.
    ///
    /// - Complexity: O(*1*), alias to ``dequeue()``.
    @inlinable
    public func next() -> Element? {
        self.removeLast()
    }
    
}

extension InlineDeque: CustomStringConvertible where Element: CustomStringConvertible {
    
    /// The description to the queue.
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


extension InlineDeque.Node: Equatable where Element: Equatable {
    
    /// Equitable implementation.
    ///
    /// The equitable implementation never checks for address, to check address, use `===` instead.
    @inlinable
    public static func == (_ lhs: InlineDeque.Node, _ rhs: InlineDeque.Node) -> Bool {
        lhs.content == rhs.content
    }
    
}


extension InlineDeque.Node: Hashable where Element: Hashable {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(content)
    }
    
}


extension Array {
    
    /// Initialize an array with a deque.
    ///
    /// - Parameters:
    ///   - deque: The source deque. Such deque borrowed to iterate.
    public init(_ deque: borrowing InlineDeque<Element>) {
        self = []
        self.reserveCapacity(deque.count)
        
        deque.forEach { element in
            self.append(element)
        }
    }
    
}
