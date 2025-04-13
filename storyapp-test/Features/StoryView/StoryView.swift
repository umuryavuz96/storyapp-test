import SwiftUI
import ComposableArchitecture
import ApiModels

@ViewAction(for: StoryViewReducer.self)
struct StoryView: View {
    let store: StoreOf<StoryViewReducer>
    var body: some View {
        VStack(spacing: 0) {
            userHeaderView
            progressBarView
            userContentView
        }
        .background(
            Color.black
                .edgesIgnoringSafeArea(.all)
        )
        .onTapGesture {
            send(.contentTapped)
        }
        .onAppear {
            send(.onAppear)
        }
        .onDisappear {
            send(.onDisappear)
        }
    }
    
    private var userContentView: some View {
        AsyncImage(url: store.story.imageURL) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if phase.error != nil {
                Image(systemName: "photo")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
            } else {
                ProgressView()
                    .scaleEffect(2.0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var userHeaderView: some View {
        HStack {
            HStack(spacing: 8) {
                AsyncImage(url: store.story.imageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                
                Text(store.story.username)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            closeButtonView
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    private var closeButtonView: some View {
        Button {
            send(.closeButtonTapped)
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(8)
        }
    }
    
    private var progressBarView: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(height: 3)
                .cornerRadius(1.5)
            
            Rectangle()
                .fill(Color.white)
                .frame(width: progressWidth, height: 3)
                .cornerRadius(1.5)
                .animation(.smooth, value: store.progress)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    private var progressWidth: CGFloat {
        let totalWidth = UIScreen.main.bounds.width - 32
        let progress = min(CGFloat(store.progress) / CGFloat(store.totalSteps), 1.0)
        return totalWidth * progress
    }
}

#Preview {
    StoryView(
        store: Store(
            initialState: StoryViewReducer.State(
                story: Story(
                    id: "1",
                    username: "preview_user",
                    imageURL: URL(string: "https://i.pravatar.cc/300?u=1")!,
                    isViewed: false
                )
            ),
            reducer: { StoryViewReducer() }
        )
    )
} 
