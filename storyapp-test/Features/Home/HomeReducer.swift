import Foundation
import ComposableArchitecture

@Reducer
public struct HomeReducer {
    
    @ObservableState
    public struct State: Equatable {
        var storyList: StoryListReducer.State = .init()
        var feedItems: [FeedItem] = []
        
        public init(
            feedItems: [FeedItem] = []
        ) {
            self.feedItems = (0..<5).map { index in
                FeedItem(
                    title: "Feed Item \(index + 1)",
                    description: "This is feed item number \(index + 1) for demonstration purposes.",
                    color: Int.random(in: 0...5)
                )
            }
        }
    }
    
    public enum Action: ViewAction, BindableAction {
        case binding(BindingAction<State>)
        case storyList(StoryListReducer.Action)
        case view(View)
        
        @CasePathable
        public enum View {
            case onAppear
        }
    }
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                if state.feedItems.isEmpty {
                    state.feedItems = (0..<5).map { index in
                        FeedItem(
                            title: "Feed Item \(index + 1)",
                            description: "This is feed item number \(index + 1) for demonstration purposes.",
                            color: Int.random(in: 0...5)
                        )
                    }
                }
                return .none
                
            default:
                return .none
            }
        }
        Scope(state: \.storyList, action: \.storyList) {
            StoryListReducer()
        }
    }
}

// Model for dummy feed content
public struct FeedItem: Identifiable, Equatable {
    public let id = UUID()
    let title: String
    let description: String
    let color: Int
    
    static var placeholder: FeedItem {
        FeedItem(
            title: "Feed Item",
            description: "This is a placeholder feed item for demonstration purposes.",
            color: Int.random(in: 0...5)
        )
    }
}
