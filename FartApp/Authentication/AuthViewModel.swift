//
//  AuthViewModel.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/7/25.
//

import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = true
    
    func signIn() {
        isAuthenticated = true
    }
}

