//
//  ConfigServiceError.swift
//  Atra
//
//  Created by Daniel Velikov on 2.07.25.
//

import Foundation

enum ConfigServiceError: LocalizedError {
    case fetchFailed(Error?)
    case decodingFailed(AppConfigKey, Error)
    case keyNotFound(String)
}

enum ConfigServiceUpdateError: LocalizedError {
    case updateFailed(Error)
    case updateListMissing
    case updateListEmpty
    case activationFailed(Error?)
}
