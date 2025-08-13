//
//  SocketDataStorage.swift
//  Atra
//
//  Created by Daniel Velikov on 11.08.25.
//

import Foundation

protocol SocketDataStorage: AnyObject, Observable {
    associatedtype Element
    associatedtype SubsetID: Hashable
    
    var cache: [String: Element] { get }
    var subsets: [SubsetID: [String]] { get }
    
    var allSubsets: [SubsetID] { get }
    
    func updateCache(with data: [Element])
    func updateSubset(with id: SubsetID, data: [String])
    
    func fetchData(for id: String) -> Element?
}
