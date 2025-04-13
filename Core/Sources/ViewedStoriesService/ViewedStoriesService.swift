import Foundation
import Dependencies
import ApiModels

public struct ViewedStory: Codable, Equatable, Identifiable {
    public let id: String
    public let username: String
    public let imageURL: URL
    public let viewedAt: Date
    
    public init(id: String, username: String, imageURL: URL, viewedAt: Date) {
        self.id = id
        self.username = username
        self.imageURL = imageURL
        self.viewedAt = viewedAt
    }
}

public struct ViewedStoriesService {
    public var markStoryAsViewed: @Sendable (Story) async -> Void
    public var isStoryViewed: @Sendable (String) async -> Bool
    public var getAllViewedStories: @Sendable () async -> [ViewedStory]
    public var clearViewedStories: @Sendable () async -> Void
    
    public init(
        markStoryAsViewed: @escaping @Sendable (Story) async -> Void,
        isStoryViewed: @escaping @Sendable (String) async -> Bool,
        getAllViewedStories: @escaping @Sendable () async -> [ViewedStory],
        clearViewedStories: @escaping @Sendable () async -> Void
    ) {
        self.markStoryAsViewed = markStoryAsViewed
        self.isStoryViewed = isStoryViewed
        self.getAllViewedStories = getAllViewedStories
        self.clearViewedStories = clearViewedStories
    }
}

extension ViewedStoriesService: DependencyKey {
    public static var liveValue = ViewedStoriesService.live
    
    public static var testValue = ViewedStoriesService(
        markStoryAsViewed: { _ in },
        isStoryViewed: { _ in false },
        getAllViewedStories: { [] },
        clearViewedStories: {}
    )
    
    public static var previewValue = ViewedStoriesService(
        markStoryAsViewed: { _ in },
        isStoryViewed: { _ in false },
        getAllViewedStories: { [] },
        clearViewedStories: {}
    )
}

extension DependencyValues {
    public var viewedStoriesService: ViewedStoriesService {
        get { self[ViewedStoriesService.self] }
        set { self[ViewedStoriesService.self] = newValue }
    }
} 
