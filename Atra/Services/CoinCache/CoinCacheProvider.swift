//
//  CoinCacheProvider.swift
//  Atra
//
//  Created by Daniel Velikov on 11.08.25.
//

import Foundation

protocol CoinCacheProvider: AnyObject, Observable {
    var cache: [String: Coin] { get }
    
    func updateCache(with data: [Coin])
    func fetchData(for id: String) -> Coin?
}
