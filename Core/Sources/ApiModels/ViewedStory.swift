import Foundation

public struct ViewedStory: Codable, Identifiable, Equatable {
    public let id: String
    public let username: String
    public let imageURL: URL
    public let viewedAt: Date
    
    public init(id: String, username: String, imageURL: URL, viewedAt: Date = Date()) {
        self.id = id
        self.username = username
        self.imageURL = imageURL
        self.viewedAt = viewedAt
    }
} 