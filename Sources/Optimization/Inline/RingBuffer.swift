//
//  RingBuffer.swift
//  Optimization
//
//  Created by Vaida on 2025-05-09.
//


/// First in, first out Queue.
///
/// A queue operates considerably faster than an `Array` when both `enqueue(_:)` and `dequeue()` operations are required. If only `enqueue` is needed, using `Array.append` would always outperform `enqueue`.
///
/// > Benchmark: `RingBuffer` is faster on removal tests than arrays on any significant size.
///
/// > Tip: This structure is preferred compared to ``Queue``.
public final class RingBuffer<Element> {
    
    // MARK: - Storage
    
    /// Underlying storage, always a power-of-two length
    @usableFromInline
    @exclusivity(unchecked)
    var buffer: UnsafeMutableBufferPointer<Element>
    
    /// Index of the first (oldest) element
    @usableFromInline
    @exclusivity(unchecked)
    var head: Int = 0
    
    @exclusivity(unchecked)
    @usableFromInline
    var _count: Int = 0
    
    /// Number of elements currently in the buffer
    @inlinable
    public var count: Int { _count }
    
    
    @inlinable
    public var capacity: Int { buffer.count }
    @inlinable
    public var isEmpty: Bool { _count == 0 }
    @inlinable
    public var isFull:  Bool { _count == capacity }
    
    
    @inlinable
    public init(minimumCapacity: Int) {
        // round up to next power of two for cheap mod-masking
        let cap = RingBuffer.nextPowerOfTwo(minimumCapacity)
        buffer = .allocate(capacity: cap)
    }
    
    @inlinable
    deinit {
        self.buffer.deallocate()
    }
    
    // MARK: - End-accessors
    
    @inlinable
    public var first: Element? {
        guard _count > 0 else { return nil }
        return buffer[head]
    }
    
    @inlinable
    public var last: Element? {
        guard _count > 0 else { return nil }
        let tailIndex = (head + _count - 1) & (capacity - 1)
        return buffer[tailIndex]
    }
    
    // MARK: - Enqueue / Dequeue
    
    @inlinable
    public func append(_ element: Element) {
        if isFull { grow() }
        let tailIndex = (head + _count) & (capacity - 1)
        buffer.initializeElement(at: tailIndex, to: element)
        _count += 1
    }
    
    @inlinable
    public func prepend(_ element: Element) {
        if isFull { grow() }
        // move head backward one slot (mod capacity)
        head = (head &- 1) & (capacity - 1)
        buffer.initializeElement(at: head, to: element)
        _count += 1
    }
    
    @discardableResult
    @inlinable
    public func removeFirst() -> Element? {
        guard _count > 0 else { return nil }
        let e = buffer[head]
        buffer.deinitializeElement(at: head)
        // advance head
        head = (head &+ 1) & (capacity - 1)
        _count -= 1
        return e
    }
    
    @discardableResult
    @inlinable
    public func removeLast() -> Element? {
        guard _count > 0 else { return nil }
        let tailIndex = (head + _count - 1) & (capacity - 1)
        let e = buffer[tailIndex]
        buffer.deinitializeElement(at: tailIndex)
        _count -= 1
        return e
    }
    
    /// Iterate through all stored elements, in FIFO order.
    ///
    /// - Parameter block: a closure to call on each element
    @inlinable
    public func forEach<E: Error>(
        _ block: (_ element: Element) throws(E) -> Void
    ) throws(E) {
        var i = 0
        while i < _count {
            // wrap (head+i) back into [0..<capacity)
            let physicalIndex = (head &+ i) & (capacity - 1)
            // we know every slot in [head, head+count) is non‐nil
            let element = buffer[physicalIndex]
            try block(element)
            i &+= 1
        }
    }
    
    
    // MARK: - Internal resize
    
    @inlinable
    func grow() {
        let oldCap = capacity
        let newCap = oldCap << 1
        let newBuf = UnsafeMutableBufferPointer<Element>.allocate(capacity: newCap)
        // copy old elements in logical order
        
        var i = 0
        while i < _count {
            newBuf.initializeElement(at: i, to: buffer[(head + i) & (oldCap - 1)])
            
            i &+= 1
        }
        buffer.deallocate()
        
        buffer = newBuf
        head = 0
    }
    
    // round up to a power of two
    @inlinable
    static func nextPowerOfTwo(_ n: Int) -> Int {
        var x = 1
        while x < n { x <<= 1 }
        return x
    }
}


extension RingBuffer {
    
    @inlinable
    public convenience init(_ collection: some Collection<Element>) {
        let count = collection.count
        self.init(minimumCapacity: count)
        
        _ = self.buffer.initialize(fromContentsOf: collection)
        self._count = count
        self.head = 0
    }
    
}


extension RingBuffer: IteratorProtocol {
    
    /// Returns the next element in the queue.
    ///
    /// - Complexity: O(*1*), alias to ``removeFirst()``.
    @inlinable
    public func next() -> Element? {
        self.removeFirst()
    }
    
}


extension RingBuffer: CustomStringConvertible where Element: CustomStringConvertible {
    
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

extension RingBuffer: ExpressibleByArrayLiteral {
    
    @inlinable
    public convenience init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
    
}


extension Array {
    
    /// Initialize an array with a deque.
    ///
    /// - Parameters:
    ///   - ring: The source deque. Such deque borrowed to iterate.
    @inlinable
    public init(_ ring: borrowing RingBuffer<Element>) {
        self = []
        self.reserveCapacity(ring._count)
        
        ring.forEach { element in
            self.append(element)
        }
    }
    
}
