import SwiftUI
import ComposableArchitecture
import ApiModels

@ViewAction(for: StoryViewReducer.self)
struct StoryViewFeature: View {
    let store: StoreOf<StoryViewReducer>
    var animation: Namespace.ID? = nil
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            // Story content
            VStack(spacing: 0) {
                // Header with user info and close button
                HStack {
                    // User info
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
                    
                    // Like button
                    likeButton
                    
                    // Close button
                    Button {
                        send(.closeButtonTapped)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Simple Progress Line
                ZStack(alignment: .leading) {
                    // Background track
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 3)
                        .cornerRadius(1.5)
                    
                    // Progress fill
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: progressWidth, height: 3)
                        .cornerRadius(1.5)
                        .animation(.linear, value: store.progress)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
                // Story image
                if let animation = animation {
                    AsyncImage(url: store.story.imageURL) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .matchedGeometryEffect(id: "story-\(store.story.id)", in: animation)
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
                } else {
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
            }
            .onTapGesture {
                send(.contentTapped)
            }
        }
        .onAppear {
            send(.onAppear)
        }
        .onDisappear {
            send(.onDisappear)
        }
    }
    
    // Calculate the progress width based on the current progress value
    private var progressWidth: CGFloat {
        let totalWidth = UIScreen.main.bounds.width - 32 // Account for horizontal padding
        let progress = min(CGFloat(store.progress) / CGFloat(store.totalSteps), 1.0) // Normalize to 0-1 range
        return totalWidth * progress
    }
    
    // Like button with appropriate styling
    private var likeButton: some View {
        Button {
            send(.likeButtonTapped)
        } label: {
            Image(systemName: store.isLiked ? "heart.fill" : "heart")
                .font(.system(size: 20))
                .foregroundColor(store.isLiked ? .red : .white)
                .padding(8)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
} 