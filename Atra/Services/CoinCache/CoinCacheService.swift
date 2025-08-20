//
//  CoinCacheService.swift
//  Atra
//
//  Created by Daniel Velikov on 11.08.25.
//

import Foundation

@Observable
final class CoinCacheService: CoinCacheProvider {
    var cache: [String: Coin] = [:]
    
    func updateCache(with data: [Coin]) {
        cache = data.reduce(into: [:]) { $0[$1.id] = $1 }
    }
    
    func fetchData(for id: String) -> Coin? {
        cache[id]
    }
}
