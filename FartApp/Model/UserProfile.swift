//
//  UserProfile.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/7/25.
//

import Foundation

struct UserProfile: Identifiable, Codable {
    var id: String
    var username: String
    var email: String
    var avatarURL: String
    var bio: String
    var followerCount: Int
    var followingCount: Int
    var postCount: Int
    var joinDate: Date
    var achievements: [String]
    
    init(id: String, username: String, email: String, avatarURL: String, bio: String, followerCount: Int, followingCount: Int, postCount: Int, joinDate: Date, achievements: [String] = []) {
        self.id = id
        self.username = username
        self.email = email
        self.avatarURL = avatarURL
        self.bio = bio
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.postCount = postCount
        self.joinDate = joinDate
        self.achievements = achievements
    }
}
