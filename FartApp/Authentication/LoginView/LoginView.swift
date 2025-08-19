//
//  LoginView.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isSignUp = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // App Logo/Title
                VStack(spacing: 10) {
                    Image(systemName: "wind")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                    
                    Text("FartApp")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Share your gassy moments")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Google Sign-In Button
                VStack(spacing: 20) {
                    Text("Quick Sign-In")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    GoogleSignInButton(action: handleGoogleSignIn)
                        .frame(height: 50)
                        .cornerRadius(12)
                        .disabled(firebaseService.isLoading)
                }
                
                // Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.secondary.opacity(0.3))
                    
                    Text("or")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.secondary.opacity(0.3))
                }
                .padding(.horizontal)
                
                // Form Fields
                VStack(spacing: 20) {
                    if isSignUp {
                        TextField("Username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                    }
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // Action Button
                Button(action: handleAuthAction) {
                    HStack {
                        if firebaseService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        
                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(firebaseService.isLoading ? Color.gray : Color.green)
                    )
                    .disabled(firebaseService.isLoading)
                }
                .padding(.horizontal)
                
                // Toggle Sign Up/Sign In
                Button(action: { isSignUp.toggle() }) {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .foregroundStyle(.green)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Authentication Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func handleGoogleSignIn() {
        Task {
            do {
                try await firebaseService.signInWithGoogle()
            } catch {
                await MainActor.run {
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
    
    private func handleAuthAction() {
        guard !email.isEmpty && !password.isEmpty else {
            alertMessage = "Please fill in all fields"
            showingAlert = true
            return
        }
        
        if isSignUp {
            guard !username.isEmpty else {
                alertMessage = "Please enter a username"
                showingAlert = true
                return
            }
            
            Task {
                do {
                    try await firebaseService.signUp(email: email, password: password, username: username)
                } catch {
                    await MainActor.run {
                        alertMessage = error.localizedDescription
                        showingAlert = true
                    }
                }
            }
        } else {
            Task {
                do {
                    try await firebaseService.signIn(email: email, password: password)
                } catch {
                    await MainActor.run {
                        alertMessage = error.localizedDescription
                        showingAlert = true
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(FirebaseService.shared)
}
