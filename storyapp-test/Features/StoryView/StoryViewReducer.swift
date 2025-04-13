import Foundation
import ComposableArchitecture
import ApiModels
import Dependencies

@Reducer
public struct StoryViewReducer {
    
    @Dependency(\.viewedStoriesService) var viewedStoriesService
        
    @ObservableState
    public struct State: Equatable {
        
        var story: Story
        var progress: Int = 0
        var isTimerRunning: Bool = false
        var isLiked: Bool = false
        
        let totalDuration: Double = 3.0
        let updateInterval: Double = 0.1
        var totalSteps: Int {
            Int(totalDuration / updateInterval) 
        }
        
        public init(
            story: Story,
            progress: Int = 0,
            isTimerRunning: Bool = false,
            isLiked: Bool = false
        ) {
            self.story = story
            self.progress = progress
            self.isTimerRunning = false
            self.isLiked = story.isLiked
        }
    }
    
    public enum Action: ViewAction {
        case startTimer
        case progressIncremented
        case timerCompleted
        case markAsViewed
        case dismiss
        case toggleLike
        case likeStatusUpdated(Bool)
        case view(View)
        
        @CasePathable
        public enum View {
            case onAppear
            case onDisappear
            case closeButtonTapped
            case contentTapped
            case likeButtonTapped
        }
    }
    
    private enum CancelID { case timer }
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                return .merge(
                    .run { [storyId = state.story.id] send in
                        let isLiked = await viewedStoriesService.isStoryLiked(storyId)
                        await send(.likeStatusUpdated(isLiked))
                    },
                    .send(.markAsViewed),
                    .send(.startTimer)
                )
                
            case .view(.onDisappear):
                return .cancel(id: CancelID.timer)
                
            case .view(.closeButtonTapped), .view(.contentTapped):
                return .send(.dismiss)
                
            case .view(.likeButtonTapped):
                return .send(.toggleLike)
                
            case .toggleLike:
                return .run { [story = state.story] send in
                    let newLikeState = await viewedStoriesService.toggleLikeStory(story)
                    await send(.likeStatusUpdated(newLikeState))
                }
                
            case .likeStatusUpdated(let isLiked):
                state.isLiked = isLiked
                state.story = Story(
                    id: state.story.id,
                    username: state.story.username,
                    imageURL: state.story.imageURL,
                    isViewed: state.story.isViewed,
                    isLiked: isLiked
                )
                return .none
                
            case .startTimer:
                state.isTimerRunning = true
                state.progress = 0
                let totalSteps = Int(state.totalDuration / state.updateInterval)
                return .run { [updateInterval=state.updateInterval] send in
                    for _ in 1...totalSteps {
                        try await Task.sleep(for: .seconds(updateInterval))
                        await send(.progressIncremented)
                    }
                    
                    await send(.timerCompleted)
                }
                .cancellable(id: CancelID.timer)
                
            case .progressIncremented:
                state.progress += 1
                return .none
                
            case .timerCompleted:
                state.isTimerRunning = false
                return .run { send in
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    await send(.dismiss)
                }
                
            case .markAsViewed:
                let story = state.story
                return .run { _ in
                    await viewedStoriesService.markStoryAsViewed(story)
                }
                
            case .dismiss:
                return .none
            }
        }
    }
} 
