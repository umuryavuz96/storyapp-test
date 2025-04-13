import SwiftUI
import ComposableArchitecture
import Components
import ApiModels

@ViewAction(for: StoryListReducer.self)
struct StoryListView: View {
    
    @Bindable
    var store: StoreOf<StoryListReducer>
    
    @Namespace private var animation
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                storiesList
                endOfListItem
            }
            .padding(.horizontal)
        }
        .onAppear {
            send(.onAppear)
        }
        .fullScreenCover(
            item: $store.scope(
                state: \.storyView,
                action: \.storyView
            )
        ) { storyViewStore in
            StoryViewFeature(
                store: storyViewStore,
                animation: animation
            )
        }
    }
    
    @ViewBuilder
    var storiesList: some View {
        ForEach(store.stories) { story in
            StoryListCellView(
                imageURL: story.imageURL,
                username: story.username,
                isViewed: story.isViewed,
                isLiked: story.isLiked,
                onTap: {
                    send(.storyTapped(story))
                }
            )
            .transition(.scale)
        }
    }
    
    @ViewBuilder
    var endOfListItem: some View {
        if store.hasMorePages {
            endOfListLoadingIndicator
        } else {
            endOfListIndicator
        }
    }
    
    private var endOfListLoadingIndicator: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 68, height: 68)
            
            if store.isLoading {
                ProgressView()
                    .frame(width: 30, height: 30)
            } else {
                Image(systemName: "plus")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 70, height: 70)
        .padding(.bottom, 15)
        .onAppear {
            send(.reachedEndOfScroll)
        }
    }
}

extension StoryListView {
    private var endOfListIndicator: some View {
        ZStack {
            LinearGradient(
                colors: [.purple, .pink, .orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: 68, height: 68)
            .clipShape(Circle())
            
            Circle()
                .fill(Color.white)
                .frame(width: 64, height: 64)
            
            Image(systemName: "checkmark")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.green)
        }
        .frame(width: 70, height: 70)
        .padding(.bottom, 15)
    }
}

#Preview {
    StoryListView(
        store: Store(
            initialState: StoryListReducer.State(),
            reducer: { StoryListReducer() }
        )
    )
}
