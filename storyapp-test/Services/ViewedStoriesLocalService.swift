import Foundation
import Dependencies
import ApiModels

// ViewedStory model for local use
public struct ViewedStory: Codable, Equatable, Identifiable {
    public let id: String
    let username: String
    let imageURL: URL
    let viewedAt: Date
    let isLiked: Bool
    
    init(id: String, username: String, imageURL: URL, viewedAt: Date, isLiked: Bool = false) {
        self.id = id
        self.username = username
        self.imageURL = imageURL
        self.viewedAt = viewedAt
        self.isLiked = isLiked
    }
}

// ViewedStoriesService implementation
struct ViewedStoriesService {
    var markStoryAsViewed: @Sendable (Story) async -> Void
    var isStoryViewed: @Sendable (String) async -> Bool
    var getAllViewedStories: @Sendable () async -> [ViewedStory]
    var clearViewedStories: @Sendable () async -> Void
    var toggleLikeStory: @Sendable (Story) async -> Bool // Returns new like state
    var isStoryLiked: @Sendable (String) async -> Bool
    
    init(
        markStoryAsViewed: @escaping @Sendable (Story) async -> Void,
        isStoryViewed: @escaping @Sendable (String) async -> Bool,
        getAllViewedStories: @escaping @Sendable () async -> [ViewedStory],
        clearViewedStories: @escaping @Sendable () async -> Void,
        toggleLikeStory: @escaping @Sendable (Story) async -> Bool,
        isStoryLiked: @escaping @Sendable (String) async -> Bool
    ) {
        self.markStoryAsViewed = markStoryAsViewed
        self.isStoryViewed = isStoryViewed
        self.getAllViewedStories = getAllViewedStories
        self.clearViewedStories = clearViewedStories
        self.toggleLikeStory = toggleLikeStory
        self.isStoryLiked = isStoryLiked
    }
}

// Live implementation
extension ViewedStoriesService {
    static var live: Self {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent("viewed_stories.json")
        
        func loadViewedStories() -> [ViewedStory] {
            do {
                if !fileManager.fileExists(atPath: fileURL.path) {
                    try "[]".write(to: fileURL, atomically: true, encoding: .utf8)
                }
                
                let data = try Data(contentsOf: fileURL)
                let stories = try JSONDecoder().decode([ViewedStory].self, from: data)
                return stories
            } catch {
                return []
            }
        }
        
        func saveViewedStories(_ stories: [ViewedStory]) {
            do {
                let data = try JSONEncoder().encode(stories)
                try data.write(to: fileURL)
            } catch {
                // Error handling is preserved by not doing anything, as in the original
            }
        }
        
        return Self(
            markStoryAsViewed: { story in
                var stories = loadViewedStories()
                if !stories.contains(where: { $0.id == story.id }) {
                    stories.append(ViewedStory(
                        id: story.id,
                        username: story.username,
                        imageURL: story.imageURL,
                        viewedAt: Date(),
                        isLiked: story.isLiked
                    ))
                    saveViewedStories(stories)
                }
            },
            isStoryViewed: { storyId in
                let stories = loadViewedStories()
                let isViewed = stories.contains(where: { $0.id == storyId })
                return isViewed
            },
            getAllViewedStories: {
                loadViewedStories()
            },
            clearViewedStories: {
                saveViewedStories([])
            },
            toggleLikeStory: { story in
                var stories = loadViewedStories()
                let newLikeState: Bool
                
                if let index = stories.firstIndex(where: { $0.id == story.id }) {
                    // Story exists, toggle like state but preserve viewed state
                    let currentLikeState = stories[index].isLiked
                    newLikeState = !currentLikeState
                    
                    // Replace the existing story with updated like state
                    stories[index] = ViewedStory(
                        id: stories[index].id,
                        username: stories[index].username,
                        imageURL: stories[index].imageURL,
                        viewedAt: stories[index].viewedAt,
                        isLiked: newLikeState
                    )
                } else {
                    // Story doesn't exist yet, create it with liked state only
                    // This is a story that has been liked but NOT viewed
                    newLikeState = true
                    stories.append(ViewedStory(
                        id: story.id,
                        username: story.username,
                        imageURL: story.imageURL,
                        viewedAt: Date(), // We need a date but this doesn't mean it's "viewed"
                        isLiked: true
                    ))
                }
                
                saveViewedStories(stories)
                return newLikeState
            },
            isStoryLiked: { storyId in
                let stories = loadViewedStories()
                return stories.first(where: { $0.id == storyId })?.isLiked ?? false
            }
        )
    }
    
    static var testValue = ViewedStoriesService(
        markStoryAsViewed: { _ in },
        isStoryViewed: { _ in false },
        getAllViewedStories: { [] },
        clearViewedStories: {},
        toggleLikeStory: { _ in false },
        isStoryLiked: { _ in false }
    )
    
    static var previewValue = ViewedStoriesService(
        markStoryAsViewed: { _ in },
        isStoryViewed: { _ in false },
        getAllViewedStories: { [] },
        clearViewedStories: {},
        toggleLikeStory: { _ in false },
        isStoryLiked: { _ in false }
    )
}

// Dependency registration
extension ViewedStoriesService: DependencyKey {
    static var liveValue: ViewedStoriesService { .live }
}

extension DependencyValues {
    var viewedStoriesService: ViewedStoriesService {
        get { self[ViewedStoriesService.self] }
        set { self[ViewedStoriesService.self] = newValue }
    }
} 
