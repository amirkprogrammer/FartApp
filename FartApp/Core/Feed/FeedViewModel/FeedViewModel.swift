//
//  FeedViewModel.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/8/25.
//

import Foundation

@MainActor
class FeedViewModel: ObservableObject {
    @Published var posts: [FartPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseService: FirebaseService
    
    init(firebaseService: FirebaseService) {
        self.firebaseService = firebaseService
        print("🔄 FeedViewModel: Initialized")
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadPosts() {
        Task {
            isLoading = true
            errorMessage = nil
            
            print("🔄 FeedViewModel: Starting to load posts...")
            
            // Re-enable Firebase for real data
            do {
                posts = try await firebaseService.getPosts(limit: 20)
                print("✅ FeedViewModel: Successfully loaded \(posts.count) posts from Firebase")
            } catch {
                print("❌ FeedViewModel: Firebase failed with error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                // Fallback to mock data if Firebase fails
                print("🔄 FeedViewModel: Falling back to mock data...")
                loadMockPosts()
                print("✅ FeedViewModel: Loaded \(posts.count) mock posts")
            }
            
            isLoading = false
        }
    }
    
    func refreshPosts() {
        Task {
            print("🔄 FeedViewModel: Refreshing posts...")
            isLoading = true
            errorMessage = nil

            do {
                posts = try await firebaseService.getPosts(limit: 20)
                print("✅ FeedViewModel: Successfully refreshed \(posts.count) posts from Firebase")
            } catch {
                print("❌ FeedViewModel: Firebase refresh failed with error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                // Fallback to mock data if Firebase fails
                print("🔄 FeedViewModel: Falling back to mock data...")
                loadMockPosts()
                print("✅ FeedViewModel: Loaded \(posts.count) mock posts")
            }
            
            isLoading = false
        }
    }
    
    func likePost(_ post: FartPost) {
        Task {
            do {
                try await firebaseService.likePost(postId: post.id)
                // Update the post in the local array
                if let index = posts.firstIndex(where: { $0.id == post.id }) {
                    posts[index].whiffCount += 1
                    posts[index].isLiked = true
                }
            } catch {
                print("Failed to like post: \(error.localizedDescription)")
            }
        }
    }
    
    func unlikePost(_ post: FartPost) {
        Task {
            do {
                try await firebaseService.unlikePost(postId: post.id)
                // Update the post in the local array
                if let index = posts.firstIndex(where: { $0.id == post.id }) {
                    posts[index].whiffCount = max(0, posts[index].whiffCount - 1)
                    posts[index].isLiked = false
                }
            } catch {
                print("Failed to unlike post: \(error.localizedDescription)")
            }
        }
    }
    
    // Fallback to mock data
    private func loadMockPosts() {
        let base = DeveloperPreview.shared.fartPost
        // Sample video URLs for testing
        let sampleVideoURLs = [
            "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
            "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
            "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"
        ]
        
        // Use consistent username that matches profile
        let consistentUsername = "gassy_greg"
        
        posts = (1...10).map { i in
            // Use different tags for each post to avoid duplicates
            let availableTags = FartTag.allCases
            let tagIndex = (i - 1) % availableTags.count
            let tag = availableTags[tagIndex]
            
            // Use different sample videos for variety
            let videoURL = sampleVideoURLs[i % sampleVideoURLs.count]
            
            let captionSuffix = ["🔥", "😂", "😳", "💨", "🎶"].randomElement() ?? ""
            return FartPost(
                id: UUID(), // Ensure unique ID for each post
                userId: base.userId,
                username: consistentUsername, // Use consistent username
                userAvatar: base.userAvatar,
                audioURL: videoURL, // Use valid video URL
                caption: "Another masterpiece from \(consistentUsername)! #\(i) \(captionSuffix)",
                tags: [tag], // Use only one unique tag per post
                intensity: max(1, min(5, base.intensity + (i % 3) - 1)),
                classification: base.classification,
                whiffCount: base.whiffCount + i * 3,
                commentCount: base.commentCount + i,
                shareCount: base.shareCount + i / 2,
                isLiked: false,
                timestamp: Date().addingTimeInterval(-Double(i) * 3600)
            )
        }
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
        print("🔄 FeedViewModel: User profile updated notification received, refreshing posts...")
        refreshPosts()
    }
}
