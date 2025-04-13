import Foundation
import ApiModels

extension NetworkService {
    public static func test(
        responses: [URL: Data] = [:],
        localFiles: [String: Data] = [:],
        delay: TimeInterval = 0
    ) -> Self {
        return Self(
            get: { url in
                try await Task.sleep(for: .seconds(delay))
                guard let data = responses[url] else {
                    throw NetworkError.invalidResponse
                }
                return data
            },
            getLocalJSON: { filename, bundle in
                try await Task.sleep(for: .seconds(delay))
                guard let data = localFiles[filename] else {
                    throw NetworkError.fileNotFound(filename: filename)
                }
                return data
            }
        )
    }
    
    public static var preview: Self {
        // Create mock users
        let mockUsers = (1...30).map { id in
            UserDto(
                id: id,
                name: "User \(id)",
                profile_picture_url: "https://i.pravatar.cc/300?u=\(id)"
            )
        }
        
        let mockURL = URL(string: "https://api.example.com/users")!
        
        // Create mock pages
        let mockPages = [
            UserPageDto(users: Array(mockUsers.prefix(10))),
            UserPageDto(users: Array(mockUsers.dropFirst(10).prefix(10))),
            UserPageDto(users: Array(mockUsers.dropFirst(20)))
        ]
        
        let mockPagesDto = UserPagesDto(pages: mockPages)
        
        return .test(
            responses: [mockURL: try! JSONEncoder().encode(mockUsers)],
            localFiles: ["users.json": try! JSONEncoder().encode(mockPagesDto)],
            delay: 0.5
        )
    }
}

// MARK: - Testing Helpers

public extension NetworkService {
    static func mockResponse<T: Encodable>(for url: URL, returning value: T) -> [URL: Data] {
        [url: try! JSONEncoder().encode(value)]
    }
    
    static func mockLocalFile<T: Encodable>(for filename: String, returning value: T) -> [String: Data] {
        [filename: try! JSONEncoder().encode(value)]
    }
} 
