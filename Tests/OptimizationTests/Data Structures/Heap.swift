//
//  Heap.swift
//  Essentials
//
//  Created by Vaida on 12/1/24.
//

import Testing
@testable
import Essentials


@Suite
struct HeapTests {
    
    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func emptyHeap(type: Heap<Int>.HeapType) async throws {
        let heap: Heap<Int> = []
        #expect(heap.isEmpty)
        #expect(heap.count == 0)
    }
    
    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func simpleAppend(type: Heap<Int>.HeapType) async throws {
        var heap = Heap<Int>(type)
        heap.append(1)
        heap.append(100)
        heap.append(2)
        heap.append(50)
        
        #expect(heap.count == 4)
        #expect(heap.first == (type == .maxHeap ? 100 : 1))
        #expect(heap.contains(1))
        #expect(heap.contains(100))
        #expect(heap.contains(2))
        #expect(heap.contains(50))
        
        if type == .maxHeap {
            #expect(heap.removeFirst() == 100)
            #expect(heap.removeFirst() == 50)
            #expect(heap.removeFirst() == 2)
            #expect(heap.removeFirst() == 1)
            #expect(heap.removeFirst() == nil)
        } else {
            #expect(heap.removeFirst() == 1)
            #expect(heap.removeFirst() == 2)
            #expect(heap.removeFirst() == 50)
            #expect(heap.removeFirst() == 100)
            #expect(heap.removeFirst() == nil)
        }
    }
    
    @Test(arguments: [Heap<Int>.HeapType.maxHeap, .minHeap])
    func sequenceAppend(type: Heap<Int>.HeapType) async throws {
        var heap = Heap<Int>(type)
        var array: [Int] = []
        while array.count < 10 {
            array.append(Int.random(in: Int.min ..< Int.max))
        }
        heap.append(contentsOf: array)
        let sorted = array.sorted(by: { type == .maxHeap ? $0 > $1 : $0 < $1 })
        
        for (lhs, rhs) in zip(sorted, heap) {
            #expect(lhs == rhs)
        }
        
        let second = Heap(type, from: array)
        for (lhs, rhs) in zip(sorted, second) {
            #expect(lhs == rhs)
        }
        
        #expect(Array(heap) == sorted)
    }
    
    @Test
    func sequenceMin() {
        var array: [Int] = []
        while array.count < 10 {
            array.append(Int.random(in: Int.min ..< Int.max))
        }
        
        #expect(array.min(k: 1) == array.min())
        #expect(array.min(k: 2) == array.sorted()[1])
        #expect(array.min(k: 3) == array.sorted()[2])
        #expect(array.min(k: 4) == array.sorted()[3])
        
        #expect(array.min(k: 100) == array.max())
    }
    
    @Test
    func sequenceMax() {
        var array: [Int] = []
        while array.count < 10 {
            array.append(Int.random(in: Int.min ..< Int.max))
        }
        
        #expect(array.max(k: 1) == array.max())
        #expect(array.max(k: 2) == array.sorted(by: >)[1])
        #expect(array.max(k: 3) == array.sorted(by: >)[2])
        #expect(array.max(k: 4) == array.sorted(by: >)[3])
        
        #expect(array.min(k: 100) == array.max())
    }
    
    @Test
    func description() {
        var heap = Heap<Int>(.minHeap)
        heap.append(1)
        heap.append(100)
        heap.append(2)
        heap.append(50)
        
        #expect(heap.description == "[1, 2, 50, 100]")
        #expect(Array(heap) == [1, 2, 50, 100])
    }
    
}
