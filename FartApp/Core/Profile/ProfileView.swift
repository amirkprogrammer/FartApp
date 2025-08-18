//
//  ProfileView.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile header
                    VStack(spacing: 16) {
                        AsyncImage(url: URL(string: viewModel.user?.avatarURL ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(.gray.opacity(0.3))
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(.circle)
                        
                        VStack(spacing: 4) {
                            Text(viewModel.user?.displayName ?? "Unknown User")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("\(viewModel.user?.username ?? "")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(viewModel.user?.bio ?? "")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Stats
                    HStack(spacing: 40) {
                        StatView(title: "Farts", value: "\(viewModel.user?.totalPosts ?? 0)")
                        StatView(title: "Whiffs", value: "\(viewModel.user?.totalLikes ?? 0)")
                        StatView(title: "Followers", value: "\(viewModel.user?.followersCount ?? 0)")
                    }
                    
                    // Achievement badges
                    if let achievements = viewModel.user?.achievements, !achievements.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Achievements")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                                ForEach(achievements, id: \.self) { achievement in
                                    AchievementBadge(achievement: achievement)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ProfileView()
}
