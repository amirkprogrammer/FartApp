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
        Task {
            await MainActor.run {
                isLoading = true
                errorMessage = nil
            }
            
            do {
                guard let currentUser = firebaseService.currentUser else {
                    await MainActor.run {
                        errorMessage = "No authenticated user found"
                        isLoading = false
                    }
                    return
                }
                
                let profile = try await firebaseService.getUserProfile(userId: currentUser.uid)
                
                await MainActor.run {
                    if let profile = profile {
                        self.userProfile = profile
                    } else {
                        errorMessage = "Failed to load user profile"
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to load user: \(error.localizedDescription)"
                    isLoading = false
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
