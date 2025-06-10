//
//  main.swift
//  Optimization
//
//  Created by Vaida on 2025-05-09.
//

import Optimization
import Foundation
import os

let deque = RingBuffer<Int>(minimumCapacity: 1000_000)
var i = 0
while i < 1000_000 {
    deque.append(i)
    
    i &+= 1
}
let date = Date()
while !deque.isEmpty {
    deque.removeFirst()
}

//var array = Array<Int>()
//array.reserveCapacity(100)
//var i = 0
//while i < 100 {
//    array.append(i)
//
//    i &+= 1
//}
//
//let date = Date()
//while !array.isEmpty {
//    array.removeFirst()
//}

if #available(macOS 10.15, *) {
    print(date.distance(to: Date())) // 5e-6
} else {
    // Fallback on earlier versions
}
