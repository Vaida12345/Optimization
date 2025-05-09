//
//  Deque.swift
//  Essentials
//
//  Created by Vaida on 2025-05-09.
//

/// First in, first out Queue where each note has both `prev` and `next`.
///
/// A queue operates considerably faster than an `Array` when both ``enqueue(_:)`` and ``dequeue()`` operations are required. If only `enqueue` is needed, using `Array.append` would outperform `enqueue` because `enqueue` involves individually allocating each node.
///
/// ## Topics
///
/// ### Sequence Accessor
/// Accessors similar to sequences
/// - ``first``
/// - ``last``
/// - ``next()``
///
/// ### Dequence Accessor
/// Accessors that expose the underlying implementation of a deque.
/// - ``front``
/// - ``back``
public final class Deque<Element> {
    
    /// The node containing the first element.
    public private(set) var front: Node?
    
    /// The node containing the last element.
    public private(set) var back: Node?
    
    /// The number of elements in the queue.
    ///
    /// - Complexity: O(*0*), stored property.
    public private(set) var count: Int
    
    /// The first element stored
    public var first: Element? {
        front?.content
    }
    
    /// The last element stored
    public var last: Element? {
        back?.content
    }
    
    /// A two-directional Node
    public final class Node {
        
        /// The content contained in the node
        public let content: Element
        
        /// The node's predecessor.
        public fileprivate(set) weak var prev: Node?
        
        /// The node's successor.
        public fileprivate(set) var next: Node?
        
        
        fileprivate init(_ content: Element) {
            self.content = content
            self.next = nil
        }
    }
    
    /// Returns whether the queue is empty.
    ///
    /// - Complexity: O(*1*)
    public var isEmpty: Bool {
        front == nil && back == nil
    }
    
    /// Crates an empty queue.
    public init() {
        self.front = nil
        self.back = nil
        self.count = 0
    }
    
    @inlinable
    public convenience init(_ sequence: some Sequence<Element>) {
        self.init()
        
        for element in sequence {
            self.append(element)
        }
    }
    
    /// Append an element to the last.
    ///
    /// - Complexity: O(*1*)
    public func append(_ element: Element) {
        let node = Node(element)
        
        if front == nil {
            assert(back == nil)
            
            self.front = node
            self.back = node
        } else {
            assert(back != nil)
            
            self.back!.next = node
            node.prev = self.back
            self.back = node
        }
        
        self.count &+= 1
    }
    
    /// Append an element to the first.
    ///
    /// - Complexity: O(*1*)
    public func prepend(_ element: Element) {
        let node = Node(element)
        
        if front == nil {
            assert(back == nil)
            
            self.front = node
            self.back = node
        } else {
            assert(back != nil)
            
            self.front?.prev = node
            node.next = self.front
            self.front = node
        }
        
        self.count &+= 1
    }
    
    /// Removes and returns the first element in the queue.
    ///
    /// On deque, the node is removed from the queue, along with the other nodes' links to it.
    ///
    /// - Complexity: O(*1*)
    public func removeFirst() -> Element? {
        guard let first = self.front else { return nil }
        
        if self.back === first {
            self.front = nil
            self.back = nil
        } else {
            self.front = self.front?.next
            self.front?.prev = nil
        }
        
        first.prev = nil
        first.next = nil
        
        count &-= 1
        return first.content
    }
    
    /// Iterate through the deque without removing any of its elements.
    @inlinable
    public func forEach<E: Error>(_ block: (_ element: Element) throws(E) -> Void) throws(E) {
        var current = front
        
        while let node = current {
            try block(node.content)
            current = node.next
        }
    }
    
    /// Removes and returns the last element in the queue.
    ///
    /// On deque, the node is removed from the queue, along with the other nodes' links to it.
    ///
    /// - Complexity: O(*1*)
    public func removeLast() -> Element? {
        guard let back = self.back else { return nil }
        
        if self.front === back {
            self.front = nil
            self.back = nil
        } else {
            self.back = self.back?.prev
            self.back?.next = nil
        }
        
        back.prev = nil
        back.next = nil
        
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
        if self.front === back {
            self.front = nil
            self.back = nil
        } else if node === self.front {
            self.front = self.front?.next
        } else if node === self.back {
            self.back = self.back?.prev
        }
        
        node.prev?.next = node.next
        node.next?.prev = node.prev
        
        node.prev = nil
        node.next = nil
        
        count &-= 1
        return node.content
    }
    
}


extension Deque: IteratorProtocol {
    
    /// Returns the next element in the queue.
    ///
    /// - Complexity: O(*1*), alias to ``dequeue()``.
    @inlinable
    public func next() -> Element? {
        self.removeLast()
    }
    
}

extension Deque: CustomStringConvertible where Element: CustomStringConvertible {
    
    /// The description to the queue.
    public var description: String {
        var current = self.front
        var description = "["
        
        while let _current = current {
            description.write(_current.content.description)
            description.write(", ")
            current = _current.next
        }
        
        if description.count != 1 {
            description.removeLast(2)
        }
        description += "]"
        return description
    }
}

extension Deque: ExpressibleByArrayLiteral {
    
    @inlinable
    public convenience init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
    
}


extension Deque.Node: Equatable where Element: Equatable {
    
    /// Equitable implementation.
    ///
    /// The equitable implementation never checks for address, to check address, use `===` instead.
    @inlinable
    public static func == (_ lhs: Deque.Node, _ rhs: Deque.Node) -> Bool {
        lhs.content == rhs.content
    }
    
}


extension Deque.Node: Hashable where Element: Hashable {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(content)
    }
    
}


extension Array {
    
    /// Initialize an array with a deque.
    ///
    /// - Parameters:
    ///   - deque: The source deque. Such deque is destroyed after initialization.
    public init(_ deque: Deque<Element>) {
        self = []
        self.reserveCapacity(deque.count)
        
        var current = deque.front
        
        while let node = current {
            self.append(node.content)
            current = node.next
        }
    }
    
}
