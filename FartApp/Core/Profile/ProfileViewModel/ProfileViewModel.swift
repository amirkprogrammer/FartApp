//
//  ProfileViewModel.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import Foundation

class ProfileViewModel: ObservableObject {
    @Published var user: UserProfile?
    
    init() {
        loadUser()
    }
    
    func loadUser() {
        user = UserProfile(
            id: "1",
            username: "demo_user",
            displayName: "Demo User",
            avatarURL: "",
            bio: "Professional fart artist 🎨💨 42",
            totalPosts: 42,
            totalLikes: 1337,
            followersCount: 502,
            achievements: ["First Fart", "100 Whiffs", "Viral Sensation"]
        )
    }
}
