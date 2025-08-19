//
//  MainTabView.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/7/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showingCamera = false
    @State private var cameraManager = CameraManager()
    @State private var homeTabTapped = false
    
    let firebaseService: FirebaseService
    
    init(firebaseService: FirebaseService) {
        self.firebaseService = firebaseService
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView(firebaseService: firebaseService)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            DiscoverView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Discover")
                }
                .tag(1)
            
            // Record button - shows camera immediately
            Color.clear
                .tabItem {
                    Image(systemName: "wind")
                    Text("Record")
                }
                .tag(2)
                .onAppear {
                    // Automatically show camera when record tab is selected
                    if selectedTab == 2 {
                        showingCamera = true
                    }
                }
            
            // Placeholder for notifications
            VStack {
                Text("Notifications")
                    .font(.title)
                    .foregroundColor(.white)
                Text("Coming soon...")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .tabItem {
                Image(systemName: "heart")
                Text("Activity")
            }
            .tag(3)
            
            ProfileView(firebaseService: firebaseService)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(.green)
        .onChange(of: selectedTab) { _, newValue in
            // Show camera when record tab is selected
            if newValue == 2 {
                showingCamera = true
            }
            
            // Scroll to top when home tab is selected
            if newValue == 0 {
                NotificationCenter.default.post(name: .scrollToTop, object: nil)
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            VideoRecorderView(cameraManager: cameraManager) { videoURL in
                // After recording is complete, save video and return to feed
                saveVideoToFeed(videoURL: videoURL)
                showingCamera = false
                selectedTab = 0 // Return to feed tab
            }
        }
    }
    
    private func saveVideoToFeed(videoURL: URL) {
        // Show post creation sheet to add caption and tags
        // This will be implemented in the next step
        print("Video saved: \(videoURL)")
        
        // For now, just upload with default values
        Task {
            do {
                let videoId = try await firebaseService.uploadVideo(
                    videoURL: videoURL,
                    caption: "New video post",
                    tags: [.squeaky]
                )
                print("Video uploaded successfully with ID: \(videoId)")
            } catch {
                print("Failed to upload video: \(error.localizedDescription)")
            }
        }
    }
}



#Preview {
    MainTabView(firebaseService: FirebaseService.shared)
}
