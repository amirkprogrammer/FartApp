//
//  ProfileView.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @StateObject private var videoCacheManager = VideoCacheManager.shared
    @State private var showingSettingsMenu = false
    @State private var showingSignOutAlert = false
    @State private var showingClearCacheAlert = false
    @State private var showingUsernameUpdate = false
    @State private var newUsername = ""
    @State private var isUpdatingUsername = false
    @State private var showingUsernameAlert = false
    @State private var usernameAlertMessage = ""
    
    init(firebaseService: FirebaseService) {
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(firebaseService: firebaseService))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        LoadingView()
                    } else if let errorMessage = viewModel.errorMessage {
                        ProfileErrorView(message: errorMessage) {
                            viewModel.refreshUser()
                        }
                    } else if let user = viewModel.user {
                        ProfileHeaderView(user: user)
                        ProfileStatsView(user: user)
                        ProfileBioView(user: user)
                        EditProfileButton()
                        UserFartsGrid()
                    } else {
                        ProfileEmptyView()
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    SettingsButton(showingSettingsMenu: $showingSettingsMenu)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.refreshUser()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .confirmationDialog("Settings", isPresented: $showingSettingsMenu) {
                SettingsMenuContent(
                    showingSignOutAlert: $showingSignOutAlert,
                    showingClearCacheAlert: $showingClearCacheAlert,
                    showingUsernameUpdate: $showingUsernameUpdate,
                    firebaseService: viewModel.firebaseService,
                    onUsernameUpdated: {
                        // Refresh profile data after username update
                        viewModel.loadUser()
                    }
                )
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Yes", role: .destructive) {
                    Task {
                        do {
                            try await viewModel.firebaseService.signOut()
                        } catch {
                            print("Failed to sign out: \(error.localizedDescription)")
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Clear Cache", isPresented: $showingClearCacheAlert) {
                Button("Yes", role: .destructive) {
                    videoCacheManager.clearCache()
                    print("✅ ProfileView: Video cache cleared.")
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to clear the video cache? This will free up space but may cause videos to load slower initially.")
            }
            .sheet(isPresented: $showingUsernameUpdate) {
                UsernameUpdateSheet(
                    newUsername: $newUsername,
                    isUpdatingUsername: $isUpdatingUsername,
                    showingUsernameAlert: $showingUsernameAlert,
                    usernameAlertMessage: $usernameAlertMessage,
                    firebaseService: viewModel.firebaseService,
                    onSuccess: {
                        // Refresh profile data after successful username update
                        viewModel.loadUser()
                    }
                )
            }
            .alert("Username Update", isPresented: $showingUsernameAlert) {
                Button("OK") { }
            } message: {
                Text(usernameAlertMessage)
            }
        }
    }
}

// MARK: - Subviews

struct ProfileHeaderView: View {
    let user: UserProfile?
    
    var body: some View {
        VStack(spacing: 16) {
            AsyncImage(url: URL(string: user?.avatarURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.gray)
            }
            
            VStack(spacing: 4) {
                Text(user?.username ?? "Unknown User")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("@\(user?.username ?? "")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct ProfileStatsView: View {
    let user: UserProfile?
    
    var body: some View {
        HStack(spacing: 40) {
            StatView(title: "Farts", value: "\(user?.postCount ?? 0)")
            StatView(title: "Following", value: "\(user?.followingCount ?? 0)")
            StatView(title: "Followers", value: "\(user?.followerCount ?? 0)")
        }
    }
}

struct ProfileBioView: View {
    let user: UserProfile?
    
    var body: some View {
        Text(user?.bio ?? "No bio available.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
    }
}

struct EditProfileButton: View {
    var body: some View {
        Button {
            // Action for editing profile
        } label: {
            Text("Edit Profile")
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 360, height: 32)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .foregroundColor(.black)
        }
    }
}

struct UserFartsGrid: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 2) {
            ForEach(0..<15) { _ in
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
            }
        }
    }
}

struct SettingsButton: View {
    @Binding var showingSettingsMenu: Bool
    
    var body: some View {
        Button {
            showingSettingsMenu = true
        } label: {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.black)
        }
    }
}

struct SettingsMenuContent: View {
    @Binding var showingSignOutAlert: Bool
    @Binding var showingClearCacheAlert: Bool
    @Binding var showingUsernameUpdate: Bool
    let firebaseService: FirebaseService
    let onUsernameUpdated: () -> Void
    
    var body: some View {
        Group {
            Button("Sign Out", role: .destructive) {
                showingSignOutAlert = true
            }
            Button("Clear Cache") {
                showingClearCacheAlert = true
            }
            Button("Clean Storage") {
                Task {
                    do {
                        try await firebaseService.cleanupOldStorage()
                        print("✅ ProfileView: Old storage cleanup initiated.")
                    } catch {
                        print("❌ ProfileView: Failed to clean storage: \(error.localizedDescription)")
                    }
                }
            }
            Button("Generate Sample Posts") {
                Task {
                    do {
                        try await firebaseService.createSamplePosts()
                        print("✅ ProfileView: Sample posts generated successfully.")
                    } catch {
                        print("❌ ProfileView: Failed to generate sample posts: \(error.localizedDescription)")
                    }
                }
            }
            Button("Update Username") {
                showingUsernameUpdate = true
            }
        }
    }
}

struct UsernameUpdateSheet: View {
    @Binding var newUsername: String
    @Binding var isUpdatingUsername: Bool
    @Binding var showingUsernameAlert: Bool
    @Binding var usernameAlertMessage: String
    let firebaseService: FirebaseService
    let onSuccess: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Update Username")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                TextField("Enter new username", text: $newUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button("Update Username") {
                    updateUsername()
                }
                .disabled(newUsername.isEmpty || isUpdatingUsername)
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func updateUsername() {
        guard !newUsername.isEmpty else { return }
        
        isUpdatingUsername = true
        
        Task {
            do {
                try await firebaseService.updateUsername(newUsername)
                await MainActor.run {
                    usernameAlertMessage = "Username updated successfully!"
                    showingUsernameAlert = true
                    isUpdatingUsername = false
                    dismiss()
                    onSuccess()
                }
            } catch {
                await MainActor.run {
                    usernameAlertMessage = "Failed to update username: \(error.localizedDescription)"
                    showingUsernameAlert = true
                    isUpdatingUsername = false
                }
            }
        }
    }
}

#Preview {
    ProfileView(firebaseService: FirebaseService.shared)
}
