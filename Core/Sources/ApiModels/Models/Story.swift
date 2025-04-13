//
//  Story.swift
//  storyapp-test
//
//  Created by Umur Yavuz on 13/4/25.
//

import Foundation

public struct Story: Equatable, Identifiable {
    public let id: String
    public let username: String
    public let imageURL: URL
    public let isViewed: Bool
    public let isLiked: Bool
    
    public init(
        id: String,
        username: String,
        imageURL: URL,
        isViewed: Bool,
        isLiked: Bool = false
    ) {
        self.id = id
        self.username = username
        self.imageURL = imageURL
        self.isViewed = isViewed
        self.isLiked = isLiked
    }
}
