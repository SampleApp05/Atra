//
//  StatusData.swift
//  Atra
//
//  Created by Daniel Velikov on 6.08.25.
//

import Foundation

struct StatusData: Codable, Equatable {
    let lastUpdated: String?
    let nextUpdate: String
    let isLoading: Bool
}
