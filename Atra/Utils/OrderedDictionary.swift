////
////  OrderedDictionary.swift
////  Atra
////
////  Created by Daniel Velikov on 19.06.25.
////
//
//import Foundation
//
//struct OrderedDictionary<Key: Hashable, Value> {
//    private(set) var storage: [Key: Value] = [:]
//    private(set) var order: [Key] = []
//    
//    mutating func push(_ key: Key, value: Value) {
//        guard storage[key] == nil else {
//            storage[key] = value
//            return
//        }
//        
//        order.append(key)
//        storage[key] = value
//    }
//    
//    mutating func remove(_ key: Key) {
//        order.removeAll { $0 == key }
//        storage.removeValue(forKey: key)
//    }
//    
//    mutating func popLast() -> Value? {
//        guard let key = order.popLast() else { return nil }
//        return storage.removeValue(forKey: key)
//    }
//}
//
//extension OrderedDictionary: Sequence {
//    func makeIterator() -> AnyIterator<(Key, Value)> {
//        var index = 0
//        
//        return AnyIterator {
//            guard index < order.count else { return nil }
//            let key = order[index]
//            index += 1
//            
//            return (key, storage.expect(key))
//        }
//    }
//}
//
//extension OrderedDictionary: RandomAccessCollection {
//    typealias Element = (Key, Value)
//    typealias Index = Int
//    
//    var startIndex: Int { order.startIndex }
//    var endIndex: Int { order.endIndex }
//    
//    func index(after i: Index) -> Index {
//        order.index(after: i)
//    }
//    
//    subscript(position: Index) -> Element {
//        let key = order[position]
//        return (key: key, value: storage.expect(key))
//    }
//}
//
//extension OrderedDictionary: ExpressibleByDictionaryLiteral {
//    init(dictionaryLiteral elements: (Key, Value)...) {
//        elements.forEach { key, value in
//            push(key, value: value)
//        }
//    }
//}
