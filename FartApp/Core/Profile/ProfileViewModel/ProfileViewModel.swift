//
//  ProfileViewModel.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import Foundation
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let firebaseService: FirebaseService
    
    init(firebaseService: FirebaseService) {
        self.firebaseService = firebaseService
        loadUser()
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func loadUser() {
        guard let currentUser = firebaseService.currentUser else {
            errorMessage = "No user is currently logged in"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if let userProfile = try await firebaseService.getUserProfile(userId: currentUser.uid) {
                    await MainActor.run {
                        self.user = userProfile
                        self.isLoading = false
                    }
                } else {
                    // Create a default profile if none exists
                    let defaultProfile = UserProfile(
                        id: currentUser.uid,
                        username: currentUser.displayName ?? "User",
                        email: currentUser.email ?? "",
                        avatarURL: currentUser.photoURL?.absoluteString ?? "",
                        bio: "Welcome to FartApp! 💨",
                        followerCount: 0,
                        followingCount: 0,
                        postCount: 0,
                        joinDate: Date()
                    )
                    
                    // Save the default profile
                    try await firebaseService.saveUserProfile(defaultProfile)
                    
                    await MainActor.run {
                        self.user = defaultProfile
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load user profile: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func refreshUser() {
        loadUser()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userProfileUpdated),
            name: .userProfileUpdated,
            object: nil
        )
    }
    
    @objc private func userProfileUpdated() {
        print("🔄 ProfileViewModel: User profile updated notification received")
        DispatchQueue.main.async {
            self.loadUser()
        }
    }
}
