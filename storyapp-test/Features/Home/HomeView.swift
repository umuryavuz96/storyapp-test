import Foundation
import SwiftUI
import ComposableArchitecture
import Components

@ViewAction(for: HomeReducer.self)
struct HomeView: View {
    
    @Bindable
    var store: StoreOf<HomeReducer>
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 16) {
                // Number of feed items debug info
                Text("Feed Items: \(store.feedItems.count)")
                    .foregroundColor(.gray)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
                
                // Story list at the top
                VStack(alignment: .leading, spacing: 8) {
                    Text("Stories")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    StoryListView(
                        store: store.scope(
                            state: \.storyList,
                            action: \.storyList
                        )
                    )
                    .frame(height: 110)
                }
                .padding(.top, 8)
                
                // Divider
                Divider()
                
                feed
            }
            .padding(.bottom, 16)
        }
        .onAppear {
            send(.onAppear)
        }
    }
}

extension HomeView {
    private func feedItemView(_ item: FeedItem) -> some View {
        let colors: [Color] = [.blue, .red, .green, .orange, .purple, .pink]
        let color = colors[item.color % colors.count]
        
        return
        Button {
            
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(item.title.prefix(1)))
                                .foregroundColor(color)
                                .fontWeight(.bold)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline)
                        
                        Text("Today")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
                
                // Content
                Rectangle()
                    .fill(color.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Text(item.title)
                                .font(.headline)
                                .padding(.top, 16)
                            
                            Spacer()
                            
                            Text(item.description)
                                .padding()
                                .multilineTextAlignment(.center)
                                .foregroundColor(color)
                            
                            Spacer()
                            
                            Text("#\(item.id.uuidString.prefix(8))")
                                .font(.caption)
                                .foregroundColor(color.opacity(0.7))
                                .padding(.bottom, 8)
                        }
                    )
                    .cornerRadius(12)
                
                // Footer
                HStack(spacing: 20) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart")
                        Text("Like")
                    }
                    .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "message")
                        Text("Comment")
                    }
                    .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .foregroundColor(.gray)
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.scale)
    }
    
    @ViewBuilder
    private var feed: some View {
        // Feed title
        HStack {
            Text("Feed")
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
        }
        .padding(.horizontal)
        
        // Dummy feed content
        LazyVStack(spacing: 16) {
            ForEach(store.feedItems) { item in
                feedItemView(item)
                    .id(item.id)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    HomeView(
        store: Store(
            initialState: HomeReducer.State(),
            reducer: { HomeReducer() }
        )
    )
}
