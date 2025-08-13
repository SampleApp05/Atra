//
//  CoinDataStorage.swift
//  Atra
//
//  Created by Daniel Velikov on 11.08.25.
//

import Foundation

@Observable
final class CoinDataStorage: SocketDataStorage {
    var cache: [String: Coin] = [:]
    var subsets: [WatchlistUpdateVariant: [String]] = [:]
    
    var allSubsets: [WatchlistUpdateVariant] { Array(subsets.keys) }
    
    func updateCache(with data: [Coin]) {
        cache = data.reduce(into: [:]) { $0[$1.id] = $1 }
    }
    
    func updateSubset(with id: WatchlistUpdateVariant,  data: [String]) {
        subsets[id] = data
    }
    
    func fetchData(for id: String) -> Coin? {
        cache[id]
    }
}
