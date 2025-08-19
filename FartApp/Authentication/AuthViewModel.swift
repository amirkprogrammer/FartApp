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
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await firebaseService.signIn(email: email, password: password)
            isLoading = false
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func signUp(email: String, password: String, username: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await firebaseService.signUp(email: email, password: password, username: username)
            isLoading = false
        } catch {
            errorMessage = "Sign up failed: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func signOut() async {
        isLoading = true
        
        do {
            try firebaseService.signOut()
            isLoading = false
        } catch {
            errorMessage = "Sign out failed: \(error.localizedDescription)"
            isLoading = false
        }
    }
}

