//
//  RESTClient+RetryConfig.swift
//  Atra
//
//  Created by Daniel Velikov on 24.06.25.
//

import Foundation

extension RESTClient {
    struct RetryConfig {
        private struct Constants {
            private static let serverErrorCodes: Set<Int> = Set(500...599)
            private static let clientErrors: Set<URLError.Code> = Set(
                [
                    .timedOut,
                    .cannotConnectToHost,
                    .networkConnectionLost,
                    .notConnectedToInternet,
                ]
            )
            
            static let errorCodes: Set<Int> = serverErrorCodes.union(clientErrors.map { $0.rawValue })
        }
        
        static let standard = RetryConfig(
            maxRetries: 3,
            delay: 0.5,
            retryableStatusCodes: Constants.errorCodes
        )
        
        let maxRetries: Int
        let delay: TimeInterval
        let retryableStatusCodes: Set<Int>
        
        init(
            maxRetries: Int,
            delay: TimeInterval,
            retryableStatusCodes: Set<Int>,
            shouldOverrideDefaultCodes: Bool = false
        ) {
            self.maxRetries = maxRetries
            self.delay = delay
            
            guard shouldOverrideDefaultCodes == false else {
                self.retryableStatusCodes = retryableStatusCodes
                return
            }
            
            self.retryableStatusCodes = Constants.errorCodes.union(retryableStatusCodes)
        }
    }
}
