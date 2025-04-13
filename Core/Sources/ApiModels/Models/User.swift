//
//  User.swift
//  storyapp-test
//
//  Created by Umur Yavuz on 13/4/25.
//

import Foundation

public struct User {
    public let id: Int
    public let name: String
    public let profileImage: URL?
    
    public init(id: Int, name: String, profileImageUrlString: String) {
        self.id = id
        self.name = name
        self.profileImage = URL(string: profileImageUrlString)
    }
}
