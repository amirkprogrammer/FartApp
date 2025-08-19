//
//  AuthViewModel.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/7/25.
//

import Foundation
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseService: FirebaseService
    
    init(firebaseService: FirebaseService) {
        self.firebaseService = firebaseService
        // Listen to Firebase authentication state changes
        isAuthenticated = firebaseService.isAuthenticated
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        // The FirebaseService already handles auth state changes
        // We just need to observe its published properties
        firebaseService.$isAuthenticated
            .assign(to: &$isAuthenticated)
    }
    
    func signUp(email: String, password: String, username: String) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        defer { 
            Task { @MainActor in
                isLoading = false
            }
        }
        
        try await firebaseService.signUp(email: email, password: password, username: username)
    }
    
    func signIn(email: String, password: String) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        defer { 
            Task { @MainActor in
                isLoading = false
            }
        }
        
        try await firebaseService.signIn(email: email, password: password)
    }
    
    func signOut() async throws {
        await MainActor.run {
            isLoading = true
        }
        
        defer { 
            Task { @MainActor in
                isLoading = false
            }
        }
        
        try firebaseService.signOut()
    }
}

