import Foundation
import ApiModels
import Dependencies

// MARK: - Implementation
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
                return try JSONDecoder().decode([ViewedStory].self, from: data)
            } catch {
                print("Error loading viewed stories: \(error)")
                return []
            }
        }
        
        func saveViewedStories(_ stories: [ViewedStory]) {
            do {
                let data = try JSONEncoder().encode(stories)
                try data.write(to: fileURL)
            } catch {
                print("Error saving viewed stories: \(error)")
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
                        viewedAt: Date()
                    ))
                    saveViewedStories(stories)
                }
            },
            isStoryViewed: { storyId in
                let stories = loadViewedStories()
                return stories.contains(where: { $0.id == storyId })
            },
            getAllViewedStories: {
                loadViewedStories()
            },
            clearViewedStories: {
                saveViewedStories([])
            }
        )
    }
}

