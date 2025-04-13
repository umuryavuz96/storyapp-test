//
//  File.swift
//  Core
//
//  Created by Umur Yavuz on 13/4/25.
//

import Foundation

public struct UserDto: Codable, Equatable {
    public let id: Int
    public let name: String
    public let profile_picture_url: String
    
    public init(id: Int, name: String, profile_picture_url: String) {
        self.id = id
        self.name = name
        self.profile_picture_url = profile_picture_url
    }
}
