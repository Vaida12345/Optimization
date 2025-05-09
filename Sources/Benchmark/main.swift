//
//  main.swift
//  Optimization
//
//  Created by Vaida on 2025-05-09.
//

import Optimization
import Foundation

let date = Date()
var deque = InlineDeque(Array(repeating: 1, count: 100000))

var current = deque.front

while let node = current {
    if Bool.random() {
        deque.remove(node)
    } else {
        current = deque.node(after: node)
//        current = node.next
    }
}

if #available(macOS 10.15, *) {
    print(date.distance(to: Date()))
}

 // 0.029324054718017578 < InlineDeque
// 0.016322970390319824 < Deque
