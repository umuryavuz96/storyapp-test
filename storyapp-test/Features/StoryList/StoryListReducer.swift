import Foundation
import ComposableArchitecture
import ApiModels
import NetworkService
import Dependencies

@Reducer
public struct StoryListReducer {
    
    @Dependency(\.networkService) var networkService
    @Dependency(\.viewedStoriesService) var viewedStoriesService
    
    @ObservableState
    public struct State: Equatable {
        var stories: [Story] = []
        var currentPage: Int = 0
        var isLoading: Bool = false
        var hasMorePages: Bool = true
        var allPages: [UserPageDto]?
        var selectedStory: Story?
        var isStoryViewPresented: Bool = false
        @Presents var storyView: StoryViewReducer.State?
        
        public init(
            stories: [Story] = [],
            currentPage: Int = 0,
            isLoading: Bool = false,
            hasMorePages: Bool = true,
            allPages: [UserPageDto]? = nil,
            selectedStory: Story? = nil,  
            isStoryViewPresented: Bool = false
        ) {
            self.stories = stories
            self.currentPage = currentPage
            self.isLoading = isLoading
            self.hasMorePages = hasMorePages
            self.allPages = allPages
            self.selectedStory = selectedStory
            self.isStoryViewPresented = isStoryViewPresented
        }
    }
    
    public enum Action: ViewAction, BindableAction {
        case binding(BindingAction<State>)
        case dataFetched(Result<UserPagesDto, Error>)
        case loadMoreStories
        case view(View)
        case storyView(PresentationAction<StoryViewReducer.Action>)
        case storyViewDismissed
        case viewedStoriesLoaded([ViewedStory])
        case updateStoryStates([Story])
        
        @CasePathable
        public enum View {
            case onAppear
            case storyTapped(Story)
            case reachedEndOfScroll
        }
    }
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                return .merge(
                    .send(.loadMoreStories),
                    .run { send in
                        let viewedStories = await viewedStoriesService.getAllViewedStories()
                        await send(.viewedStoriesLoaded(viewedStories))
                    }
                )
                
            case .viewedStoriesLoaded(let viewedStories):
                // Update stories based on loaded viewed stories
                var updatedStories: [Story] = []
                
                for story in state.stories {
                    let matchingViewedStory = viewedStories.first(where: { $0.id == story.id })
                    
                    if let matchingViewedStory = matchingViewedStory {
                        // Story exists in storage, update with its states
                        let updatedStory = Story(
                            id: story.id,
                            username: story.username,
                            imageURL: story.imageURL,
                            isViewed: true,
                            isLiked: matchingViewedStory.isLiked
                        )
                        updatedStories.append(updatedStory)
                    } else {
                        updatedStories.append(story)
                    }
                }
                
                if !updatedStories.isEmpty {
                    return .send(.updateStoryStates(updatedStories))
                }
                
                return .none
                
            case .updateStoryStates(let updatedStories):
                // Create a dictionary for faster lookups
                let storyDict = Dictionary(uniqueKeysWithValues: updatedStories.map { ($0.id, $0) })
                
                // Update only the stories that need updating
                for i in 0..<state.stories.count {
                    if let updatedStory = storyDict[state.stories[i].id] {
                        if state.stories[i].isViewed != updatedStory.isViewed || 
                           state.stories[i].isLiked != updatedStory.isLiked {
                            state.stories[i] = updatedStory
                        }
                    }
                }
                
                return .none
                
            case .loadMoreStories:
                guard !state.isLoading && state.hasMorePages else { return .none }
                state.isLoading = true
                
                // If this is the first load, use fetchInitialStories
                if state.allPages == nil {
                    return fetchInitialStories()
                }
                
                return loadNextPage(currentPage: state.currentPage, allPages: state.allPages)
                
            case .dataFetched(.failure(let error)):
                print(error)
                state.isLoading = false
                return .none
                
            case .dataFetched(.success(let data)):
                if state.allPages == nil {
                    state.allPages = data.pages
                    let newStories = createStoriesFromPage(data.pages.first)
                    state.stories.append(contentsOf: newStories)
                    state.currentPage = 1
                    state.isLoading = false
                    state.hasMorePages = state.currentPage < data.pages.count
                    
                    // Check viewed status for new stories
                    let storyIds = newStories.map { $0.id }
                    return .run { [storyIds] send in
                        let viewedStories = await viewedStoriesService.getAllViewedStories()
                        let relevantViewedStories = viewedStories.filter { storyIds.contains($0.id) }
                        await send(.viewedStoriesLoaded(relevantViewedStories))
                    }
                } else {
                    let newStories = createStoriesFromPage(data.pages.first)
                    state.stories.append(contentsOf: newStories)
                    state.currentPage += 1
                    state.isLoading = false
                    state.hasMorePages = state.currentPage < (state.allPages?.count ?? 0)
                    
                    // Check viewed status for new stories
                    let storyIds = newStories.map { $0.id }
                    return .run { [storyIds] send in
                        let viewedStories = await viewedStoriesService.getAllViewedStories()
                        let relevantViewedStories = viewedStories.filter { storyIds.contains($0.id) }
                        await send(.viewedStoriesLoaded(relevantViewedStories))
                    }
                }
                
            case let .view(.storyTapped(story)):
                // Set up StoryView state and present it
                state.storyView = StoryViewReducer.State(story: story)
                return .none
                
            case .view(.reachedEndOfScroll):
                return .send(.loadMoreStories)
                
            case .storyView(.presented(.dismiss)):
                // Handle dismiss from story view
                return .send(.storyViewDismissed)
                
            case .storyViewDismissed:
                // Clean up after story view is dismissed
                state.isStoryViewPresented = false
                state.selectedStory = nil
                state.storyView = nil
                
                // Refresh viewed stories data after dismissal
                return .run { send in
                    let viewedStories = await viewedStoriesService.getAllViewedStories()
                    await send(.viewedStoriesLoaded(viewedStories))
                }
                
            default:
                return .none
            }
        }
        .ifLet(\.$storyView, action: \.storyView) {
            StoryViewReducer()
        }
    }
}

// MARK: - Network Service Extension
extension StoryListReducer {
    func fetchInitialStories() -> Effect<Action> {
        .run { send in
            do {
                let url = Bundle.main.url(forResource: "users", withExtension: "json")
                guard let fileURL = url else {
                    await send(.dataFetched(.failure(NetworkError.fileNotFound(filename: "users.json"))))
                    return
                }
                
                let data = try Data(contentsOf: fileURL)
                let response = try JSONDecoder().decode(UserPagesDto.self, from: data)
                await send(.dataFetched(.success(response)))
            } catch {
                await send(.dataFetched(.failure(error)))
            }
        }
    }
    
    func loadNextPage(currentPage: Int, allPages: [UserPageDto]?) -> Effect<Action> {
        .run { send in
            guard let allPages = allPages, currentPage < allPages.count else {
                return
            }
            
            try await Task.sleep(nanoseconds: 1_500_000_000)
            
            let nextPage = allPages[currentPage]
            let pageDto = UserPagesDto(pages: [nextPage])
            
            await send(.dataFetched(.success(pageDto)))
        }
    }
    
    func createStoriesFromPage(_ page: UserPageDto?) -> [Story] {
        guard let page = page else { return [] }
        
        var stories: [Story] = []
        for user in page.users {
            if let imageURL = URL(string: user.profile_picture_url) {
                let story = Story(
                    id: String(user.id),
                    username: user.name,
                    imageURL: imageURL,
                    isViewed: false,
                    isLiked: false
                )
                stories.append(story)
            }
        }
        
        return stories
    }
}

// MARK: - Network Errors
enum NetworkError: Error {
    case fileNotFound(filename: String)
}

