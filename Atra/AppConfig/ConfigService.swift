//
//  ConfigService.swift
//  Atra
//
//  Created by Daniel Velikov on 2.07.25.
//

import Foundation

protocol ConfigService {
    var updateStream: AsyncThrowingStream<Set<String>, Error> { get }
    
    func configure()
    func fetch() async throws
    func fetchValue<T: Decodable>(for key: AppConfigKey) throws -> T
}
