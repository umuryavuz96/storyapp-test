import Dependencies
import Foundation

public struct NetworkService {
    public var get: @Sendable (_ url: URL) async throws -> Data
    public var getLocalJSON: @Sendable (_ filename: String, _ bundle: Bundle) async throws -> Data
    
    public func getJSON<T: Decodable>(_ url: URL, type: T.Type) async throws -> T {
        let data = try await get(url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func getLocalJSON<T: Decodable>(_ filename: String, type: T.Type, bundle: Bundle = .main) async throws -> T {
        let data = try await getLocalJSON(filename, bundle)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Dependencies

extension NetworkService: DependencyKey {
    public static var liveValue: NetworkService = .live
}

extension DependencyValues {
    public var networkService: NetworkService {
        get { self[NetworkService.self] }
        set { self[NetworkService.self] = newValue }
    }
} 
