//
//  FirebaseConfigService.swift
//  Atra
//
//  Created by Daniel Velikov on 2.07.25.
//

import FirebaseRemoteConfig

final class FirebaseConfigService: ConfigService {
    private(set) var fetcher: FirebaseConfigFetcher
    
    init(fetcher: FirebaseConfigFetcher = RemoteConfig.remoteConfig()) {
        self.fetcher = fetcher
    }
    
    private(set) lazy var updateStream: AsyncThrowingStream<Set<String>, Error> = {
        AsyncThrowingStream { (continuation) in
            fetcher.addUpdateListener { [weak self] (update, error) in
                if let error = error {
                    continuation.yield(with: .failure(ConfigServiceError.updateFailed(error)))
                    return
                }
                
                guard let keys = update?.updatedKeys else {
                    continuation.yield(with: .failure(ConfigServiceError.updateListMissing))
                    return
                }
                
                guard keys.isEmpty == false else {
                    continuation.yield(with: .failure(ConfigServiceError.updateListEmpty))
                    return
                }
                
                self?.fetcher.applyUpdates { (success, error) in
                    if let error = error {
                        continuation.yield(with: .failure(ConfigServiceError.activationFailed(error)))
                        return
                    }
                    
                    guard success else {
                        continuation.yield(with: .failure(ConfigServiceError.activationFailed(nil)))
                        return
                    }
                    
                    continuation.yield(with: .success(keys))
                }
            }
        }
    }()
 
    func configure() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600 // 1 hour
        fetcher.configSettings = settings
    }
    
    func fetch() async throws {
        do {
            let result = try await fetcher.fetchAndActivate()
            
            if result.didSucceed == false {
                throw ConfigServiceError.fetchFailed(nil)
            }
        } catch {
            throw ConfigServiceError.fetchFailed(error)
        }
    }
    
    func fetchValue<T: Decodable>(for key: AppConfigKey) throws -> T {
        let data = fetcher[key.rawValue].dataValue
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Failed to decode value for key \(key.rawValue): \(error)")
            throw ConfigServiceError.decodingFailed(key, error)
        }
    }
}
