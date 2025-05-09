//
//  Queue.swift
//  Algorithms
//
//  Created by Vaida on 10/17/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//


/// First in, first out Queue.
///
/// A queue operates considerably faster than an `Array` when both ``enqueue(_:)`` and ``dequeue()`` operations are required. If only `enqueue` is needed, using `Array.append` would outperform `enqueue` because `enqueue` involves individually allocating each node.
public final class Queue<Element> {
    
    private var front: Node?
    
    private var back: Node?
    
    /// The number of elements in the queue.
    ///
    /// - Complexity: O(*0*), stored property.
    public private(set) var count: Int
    
    /// An one-directional Node
    private final class Node {
        let content: Element
        var next: Node?
        
        init(_ content: Element) {
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
    
    public convenience init(_ sequence: some Sequence<Element>) {
        self.init()
        
        for element in sequence {
            self.enqueue(element)
        }
    }
    
    /// Iterate through the deque without removing any of its elements.
    public func forEach<E: Error>(_ block: (_ element: Element) throws(E) -> Void) throws(E) {
        var current = front
        
        while let node = current {
            try block(node.content)
            current = node.next
        }
    }
    
    /// Append an element to the last.
    ///
    /// - Complexity: O(*1*)
    public func enqueue(_ element: Element) {
        let node = Node(element)
        
        if front == nil {
            assert(back == nil)
            
            self.front = node
            self.back = node
        } else {
            assert(back != nil)
            
            self.back!.next = node
            self.back = node
        }
        
        self.count &+= 1
    }
    
    /// Removes and returns the first element in the queue.
    ///
    /// - Complexity: O(*1*)
    public func dequeue() -> Element? {
        guard let first = self.front else { return nil }
        
        if self.back === first {
            self.front = nil
            self.back = nil
        } else {
            self.front = self.front!.next
        }
        
        count &-= 1
        return first.content
    }
    
}


extension Queue: IteratorProtocol {
    
    /// Returns the next element in the queue.
    ///
    /// - Complexity: O(*1*), alias to ``dequeue()``.
    @inlinable
    public func next() -> Element? {
        self.dequeue()
    }
    
}

extension Queue: CustomStringConvertible where Element: CustomStringConvertible {
    
    /// The description to the queue.
    public var description: String {
        var current = self.front
        var description = "["
        
        while let _current = current {
            description.write(_current.content.description)
            current = _current.next
            description.write(", ")
        }
        
        if description.count != 1 {
            description.removeLast(2)
        }
        description += "]"
        return description
    }
}

extension Queue: ExpressibleByArrayLiteral {
    
    public convenience init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
    
}
