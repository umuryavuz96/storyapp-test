import Dependencies
import Foundation

@MainActor
public struct CacheService {
    // Core functionality with Data
    public var set: @Sendable (_ value: Data, _ key: String) -> Void
    public var get: @Sendable (_ key: String) -> Data?
    public var remove: @Sendable (_ key: String) -> Void
    public var clear: @Sendable () -> Void
    
    public init(
        set: @escaping @Sendable (_ value: Data, _ key: String) -> Void,
        get: @escaping @Sendable (_ key: String) -> Data?,
        remove: @escaping @Sendable (_ key: String) -> Void,
        clear: @escaping @Sendable () -> Void
    ) {
        self.set = set
        self.get = get
        self.remove = remove
        self.clear = clear
    }
    
    // Generic helper methods
    public func setObject<T: Codable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        set(data, key)
    }
    
    public func getObject<T: Codable>(forKey key: String) -> T? {
        guard let data = get(key),
              let object = try? JSONDecoder().decode(T.self, from: data)
        else { return nil }
        return object
    }
}

extension CacheService: DependencyKey {
    public static var liveValue: CacheService = .live
}

extension DependencyValues {
    public var cacheService: CacheService {
        get { self[CacheService.self] }
        set { self[CacheService.self] = newValue }
    }
} 
