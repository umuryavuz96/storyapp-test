import Foundation

extension NetworkService {
    public static var live: Self {
        let session = URLSession.shared
        
        return Self(
            get: { url in
                let (data, response) = try await session.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode)
                }
                
                return data
            },
            getLocalJSON: { filename, bundle in
                guard let url = bundle.url(forResource: filename, withExtension: nil) else {
                    throw NetworkError.fileNotFound(filename: filename)
                }
                
                return try Data(contentsOf: url)
            }
        )
    }
}

// MARK: - Errors

public enum NetworkError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case encodingError(Error)
    case fileNotFound(filename: String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .fileNotFound(let filename):
            return "File not found: \(filename)"
        }
    }
} 