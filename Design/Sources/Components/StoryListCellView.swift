//
//  File.swift
//  Design
//
//  Created by Umur Yavuz on 13/4/25.
//

import SwiftUI

public struct StoryListCellView: View {
    private let imageURL: URL
    private let username: String
    private let isViewed: Bool
    private let isLiked: Bool
    private let onTap: () -> Void
    
    public init(
        imageURL: URL,
        username: String,
        isViewed: Bool = false,
        isLiked: Bool = false,
        onTap: @escaping () -> Void = {}
    ) {
        self.imageURL = imageURL
        self.username = username
        self.isViewed = isViewed
        self.isLiked = isLiked
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Profile picture with gradient border
                ZStack {
                    // Gradient border - use different colors based on viewed/liked state
                    let borderColors: [Color] = {
                        if isLiked {
                            // Liked - always show gray border
                            return [.gray.opacity(0.3), .gray.opacity(0.3)]
                        } else if isViewed {
                            // Viewed but not liked - gray
                            return [.gray.opacity(0.3), .gray.opacity(0.3)]
                        } else {
                            // Not viewed, not liked - colorful gradient
                            return [.purple, .pink, .orange]
                        }
                    }()
                    
                    LinearGradient(
                        colors: borderColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 68, height: 68)
                    .clipShape(Circle())
                    
                    // Profile picture
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    
                    // Liked indicator
                    if isLiked {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 12))
                            .padding(4)
                            .background(Circle().fill(Color.white))
                            .offset(x: 24, y: -24)
                    }
                }
                
                // Username
                Text(username)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 70)
            }
            .frame(width: 70)
        }
        .buttonStyle(.scale)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isViewed = false
        @State private var isLiked = false
        
        var body: some View {
            VStack(spacing: 20) {
                // Toggles for both states
                VStack {
                    Toggle("Viewed State", isOn: $isViewed)
                    Toggle("Liked State", isOn: $isLiked)
                }
                .padding()
                
                Text("All possible combinations:")
                    .font(.headline)
                
                // Story Cells Preview - All combinations
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Not viewed, not liked
                        StoryListCellView(
                            imageURL: URL(string: "https://i.pravatar.cc/300?u=11")!,
                            username: "Not viewed\nNot liked\n(colorful)",
                            isViewed: false,
                            isLiked: false,
                            onTap: { print("Tapped story 1") }
                        )
                        
                        // Viewed, not liked
                        StoryListCellView(
                            imageURL: URL(string: "https://i.pravatar.cc/300?u=12")!,
                            username: "Viewed\nNot liked\n(gray)",
                            isViewed: true,
                            isLiked: false,
                            onTap: { print("Tapped story 2") }
                        )
                        
                        // Not viewed, liked
                        StoryListCellView(
                            imageURL: URL(string: "https://i.pravatar.cc/300?u=13")!,
                            username: "Not viewed\nLiked\n(gray)",
                            isViewed: false,
                            isLiked: true,
                            onTap: { print("Tapped story 3") }
                        )
                        
                        // Viewed and liked
                        StoryListCellView(
                            imageURL: URL(string: "https://i.pravatar.cc/300?u=14")!,
                            username: "Viewed\nLiked\n(gray)",
                            isViewed: true,
                            isLiked: true,
                            onTap: { print("Tapped story 4") }
                        )
                        
                        // Dynamic state
                        StoryListCellView(
                            imageURL: URL(string: "https://i.pravatar.cc/300?u=15")!,
                            username: "Dynamic",
                            isViewed: isViewed,
                            isLiked: isLiked,
                            onTap: { print("Tapped dynamic") }
                        )
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    return PreviewWrapper()
}
