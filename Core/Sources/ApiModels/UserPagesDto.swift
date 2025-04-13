//
//  UserPagesDto.swift
//  Core
//
//  Created by Umur Yavuz on 13/4/25.
//

import Foundation

public struct UserPagesDto: Codable, Equatable {
    public let pages: [UserPageDto]
    
    public init(pages: [UserPageDto]) {
        self.pages = pages
    }
}

public struct UserPageDto: Codable, Equatable {
    public let users: [UserDto]
    
    public init(users: [UserDto]) {
        self.users = users
    }
}
