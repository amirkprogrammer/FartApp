//
//  UserProfile.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/7/25.
//

import Foundation

struct UserProfile: Identifiable {
    let id: String
    let username: String
    let displayName: String
    let avatarURL: String
    let bio: String
    let totalPosts: Int
    let totalLikes: Int
    let followersCount: Int
    let achievements: [String]
}
