//
//  PriorityQueue.swift
//  Algorithms
//
//  Created by Vaida on 10/18/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//


/// First in, first out Queue with weights using heap.
///
/// The type `Element` is the content, `W` is the type for weight.
///
/// A `PriorityQueue` is both an iterator and a sequence. When forming such iterator, a copy of the queue is made, ensuring the original copy is intact during iteration.
///
/// - Warning: `PriorityQueue`s are not stable, and does not guarantee FIFO.
public struct PriorityQueue<Element, W> where W: Comparable {
    
    @usableFromInline
    internal var contents: Heap<Node>
    
    public struct Node: Comparable {
        
        public fileprivate(set) var content: Element
        public fileprivate(set) var weight: W
        
        @usableFromInline
        internal init(_ content: Element, weight: W) {
            self.content = content
            self.weight = weight
        }
        
        public static func < (lhs: PriorityQueue<Element, W>.Node, rhs: PriorityQueue<Element, W>.Node) -> Bool {
            lhs.weight < rhs.weight
        }
        
        public static func == (lhs: PriorityQueue<Element, W>.Node, rhs: PriorityQueue<Element, W>.Node) -> Bool {
            lhs.weight == rhs.weight
        }
    }
    
    /// The number of elements in the queue.
    @inlinable
    public var count: Int {
        self.contents.count
    }
    
    /// Returns whether the queue is empty.
    @inlinable
    public var isEmpty: Bool {
        self.contents.isEmpty
    }
    
    /// Creates the queue.
    ///
    /// - Parameters:
    ///   - order: The order determining how the elements will be sorted.
    @inlinable
    public init(_ order: WeightOrder = .descending) {
        self.contents = .init(order == .descending ? .maxHeap : .minHeap)
    }
    
    /// Up-heap
    ///
    /// - Complexity: O(log *n*), where *n*: length of heap
    @inlinable
    public mutating func enqueue(_ content: Element, weight: W) {
        let node = Node(content, weight: weight)
        self.contents.append(node)
    }
    
    /// Enqueue an object whose weight is itself.
    ///
    /// - Complexity: O(log *n*), where *n*: length of heap
    @inlinable
    public mutating func enqueue(_ content: Element) where Element == W {
        self.enqueue(content, weight: content)
    }
    
    /// Up-heap
    ///
    /// - Complexity: O(log *n*), where *n*: length of heap
    @inlinable
    public mutating func enqueue(_ content: Element, weight: KeyPath<Element, W>) {
        self.enqueue(content, weight: content[keyPath: weight])
    }
    
    /// Dequeue the element of priority.
    ///
    /// - Complexity: O(log *n*), where *n*: length of heap
    @inlinable
    public mutating func dequeue() -> Element? {
        self.contents.removeFirst()?.content
    }
    
    /// Dequeue the element of priority.
    ///
    /// - Parameters:
    ///   - weight: Pass a value if you need to know the weight. Otherwise, use ``dequeue()`` instead.
    ///
    /// - Complexity: O(log *n*), where *n*: length of heap
    @inlinable
    public mutating func dequeue(weight: inout W) -> Element? {
        guard let value = self.contents.removeFirst() else { return nil }
        weight = value.weight
        return value.content
    }
    
    @inlinable
    public mutating func removeAll() {
        self.contents.removeAll()
    }
    
    /// The root of the heap.
    ///
    /// - Complexity: O(*0*)
    @inlinable
    public func peek() -> Node? {
        self.contents.peek()
    }
    
    /// The order for sorting by the weight.
    public enum WeightOrder: Equatable, Sendable {
        /// elements with lower weight will be dequeued first.
        case ascending
        /// elements with higher weight will be dequeued first.
        case descending
    }
}


extension PriorityQueue: IteratorProtocol {
    
    /// The next element of the iterator.
    @inlinable
    public mutating func next() -> Element? {
        self.dequeue()
    }
    
}

extension PriorityQueue: Sequence { }


extension PriorityQueue.Node: Sendable where Element: Sendable, W: Sendable { }

extension PriorityQueue: Sendable where Element: Sendable, W: Sendable { }


extension PriorityQueue: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        "[" + self.map({ "\($0)" }).joined(separator: ", ") + "]"
    }
    
}

extension PriorityQueue: CustomDebugStringConvertible {
    
    @inlinable
    public var debugDescription: String {
        "[" + self.contents.map({ "\($0.content)<\($0.weight)>" }).joined(separator: ", ") + "]"
    }
    
}
