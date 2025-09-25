//
//  FirebaseConfigService.swift
//  Atra
//
//  Created by Daniel Velikov on 2.07.25.
//

import Firebase
import FirebaseRemoteConfig

final class FirebaseConfigService: ConfigService {
    typealias FetcherBuilderClosure = () -> FirebaseConfigFetcher
    
    private(set) var fetcher: FirebaseConfigFetcher
    
    private(set) lazy var updateStream: AsyncThrowingStream<Set<String>, Error> = {
        AsyncThrowingStream { (continuation) in
            fetcher.addUpdateListener { [weak self] (update, error) in
                if let error = error {
                    continuation.yield(with: .failure(ConfigServiceUpdateError.updateFailed(error)))
                    return
                }
                
                guard let keys = update?.updatedKeys else {
                    continuation.yield(with: .failure(ConfigServiceUpdateError.updateListMissing))
                    return
                }
                
                guard keys.isEmpty == false else {
                    continuation.yield(with: .failure(ConfigServiceUpdateError.updateListEmpty))
                    return
                }
                
                self?.fetcher.applyUpdates { (success, error) in
                    if let error = error {
                        continuation.yield(with: .failure(ConfigServiceUpdateError.activationFailed(error)))
                        return
                    }
                    
                    guard success else {
                        continuation.yield(with: .failure(ConfigServiceUpdateError.activationFailed(nil)))
                        return
                    }
                    
                    continuation.yield(with: .success(keys))
                }
            }
        }
    }()
    
    /// Initializes a new `FirebaseConfigService` instance.
    ///
    /// - Parameters:
    ///   - name: An optional name for the Firebase app instance. If provided, a named app is configured to avoid conflicts with the default app (e.g., in tests or multiple app scenarios).
    ///   - fetcher: A closure returning a `FirebaseConfigFetcher` instance, used for dependency injection and testing. Defaults to the shared `RemoteConfig` instance.
    ///
    /// - Note: The Firebase app is configured during initialization, using the provided name if available.
    init(with name: String? = nil, fetcher: @escaping FetcherBuilderClosure = { RemoteConfig.remoteConfig() }) {
        Self.configure(with: name)
        self.fetcher = fetcher()
    }
    
    // MARK: - Private
    
    /// Configures the Firebase app instance.
    ///
    /// - Parameter name: An optional name for the Firebase app. If specified, configures a named app using default options. Otherwise, configures the default app.
    ///
    /// - Important: This method is called during initialization and should not be called directly.
    private static func configure(with name: String?) {
        if let name = name, let options = FirebaseOptions.defaultOptions() {
            FirebaseApp.configure(name: name, options: options)
            return
        }
        
        FirebaseApp.configure()
    }
    
    // MARK: - Public
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
