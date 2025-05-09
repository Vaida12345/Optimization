//
//  RingBuffer.swift
//  Optimization
//
//  Created by Vaida on 2025-05-09.
//


public final class RingBuffer<Element> {
    
    // MARK: - Storage
    
    // Underlying storage, always a power-of-two length
    private var buffer: UnsafeMutableBufferPointer<Element>
    
    // Index of the first (oldest) element
    private var head: Int = 0
    
    // Number of elements currently in the buffer
    public private(set) var count: Int = 0
    
    public var capacity: Int { buffer.count }
    public var isEmpty: Bool { count == 0 }
    public var isFull:  Bool { count == capacity }
    
    
    public init(minimumCapacity: Int) {
        // round up to next power of two for cheap mod-masking
        let cap = RingBuffer.nextPowerOfTwo(minimumCapacity)
        buffer = .allocate(capacity: cap)
    }
    
    deinit {
        self.buffer.deallocate()
    }
    
    // MARK: - End-accessors
    
    public var first: Element? {
        guard count > 0 else { return nil }
        return buffer[head]
    }
    
    public var last: Element? {
        guard count > 0 else { return nil }
        let tailIndex = (head + count - 1) & (capacity - 1)
        return buffer[tailIndex]
    }
    
    // MARK: - Enqueue / Dequeue
    
    public func append(_ element: Element) {
        if isFull { grow() }
        let tailIndex = (head + count) & (capacity - 1)
        buffer.initializeElement(at: tailIndex, to: element)
        count += 1
    }
    
    public func prepend(_ element: Element) {
        if isFull { grow() }
        // move head backward one slot (mod capacity)
        head = (head &- 1) & (capacity - 1)
        buffer.initializeElement(at: head, to: element)
        count += 1
    }
    
    @discardableResult
    public func removeFirst() -> Element? {
        guard count > 0 else { return nil }
        let e = buffer[head]
        buffer.deinitializeElement(at: head)
        // advance head
        head = (head &+ 1) & (capacity - 1)
        count -= 1
        return e
    }
    
    @discardableResult
    public func removeLast() -> Element? {
        guard count > 0 else { return nil }
        let tailIndex = (head + count - 1) & (capacity - 1)
        let e = buffer[tailIndex]
        buffer.deinitializeElement(at: tailIndex)
        count -= 1
        return e
    }
    
    /// Iterate through all stored elements, in FIFO order.
    ///
    /// - Parameter block: a closure to call on each element
    public func forEach<E: Error>(
        _ block: (_ element: Element) throws(E) -> Void
    ) throws(E) {
        var i = 0
        while i < count {
            // wrap (head+i) back into [0..<capacity)
            let physicalIndex = (head &+ i) & (capacity - 1)
            // we know every slot in [head, head+count) is non‐nil
            let element = buffer[physicalIndex]
            try block(element)
            i &+= 1
        }
    }
    
    
    // MARK: - Internal resize
    
    private func grow() {
        let oldCap = capacity
        let newCap = oldCap << 1
        let newBuf = UnsafeMutableBufferPointer<Element>.allocate(capacity: newCap)
        // copy old elements in logical order
        
        var i = 0
        while i < count {
            newBuf.initializeElement(at: i, to: buffer[(head + i) & (oldCap - 1)])
            
            i &+= 1
        }
        buffer.deallocate()
        
        buffer = newBuf
        head = 0
    }
    
    // round up to a power of two
    private static func nextPowerOfTwo(_ n: Int) -> Int {
        var x = 1
        while x < n { x <<= 1 }
        return x
    }
}


extension RingBuffer {
    
    public convenience init(_ collection: some Collection<Element>) {
        let count = collection.count
        self.init(minimumCapacity: count)
        
        _ = self.buffer.initialize(fromContentsOf: collection)
        self.count = count
        self.head = 0
    }
    
}


extension RingBuffer: IteratorProtocol {
    
    /// Returns the next element in the queue.
    ///
    /// - Complexity: O(*1*), alias to ``dequeue()``.
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
    ///   - deque: The source deque. Such deque borrowed to iterate.
    @inlinable
    public init(_ ring: borrowing RingBuffer<Element>) {
        self = []
        self.reserveCapacity(ring.count)
        
        ring.forEach { element in
            self.append(element)
        }
    }
    
}
