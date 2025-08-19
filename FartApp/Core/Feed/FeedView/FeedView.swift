//
//  FeedView.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/8/25.
//

import SwiftUI
import AVKit

struct FeedView: View {
    @StateObject private var viewModel: FeedViewModel
    @StateObject private var videoCacheManager = VideoCacheManager.shared
    @State private var scrollPosition: String?
    @State private var scrollToTopTrigger = false
    @State private var hasUserInteracted = false
    @State private var initialLoadComplete = false
    
    init(firebaseService: FirebaseService) {
        self._viewModel = StateObject(wrappedValue: FeedViewModel(firebaseService: firebaseService))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.posts.isEmpty {
                EmptyFeedView()
            } else {
                FeedScrollView(
                    posts: viewModel.posts,
                    scrollPosition: $scrollPosition,
                    videoCacheManager: videoCacheManager,
                    onRefresh: refreshFeed,
                    scrollToTopTrigger: $scrollToTopTrigger,
                    hasUserInteracted: $hasUserInteracted,
                    initialLoadComplete: $initialLoadComplete
                )
            }
        }
        .onAppear {
            print("🔄 FeedView: onAppear called")
            viewModel.loadPosts()
        }
        .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
            scrollToTopTrigger.toggle()
        }
    }
    
    // MARK: - Helper Methods
    
    @MainActor
    private func refreshFeed() async {
        print("🔄 FeedView: Pull to refresh triggered")
        viewModel.refreshPosts()
    }
}

// MARK: - Subviews

struct EmptyFeedView: View {
    var body: some View {
        VStack {
            Text("No farts yet!")
                .foregroundColor(.white)
                .font(.title2)
            Text("Record your first fart to get started")
                .foregroundColor(.gray)
                .font(.subheadline)
                .padding(.top, 4)
        }
    }
}

struct FeedScrollView: View {
    let posts: [FartPost]
    @Binding var scrollPosition: String?
    let videoCacheManager: VideoCacheManager
    let onRefresh: () async -> Void
    @Binding var scrollToTopTrigger: Bool
    @Binding var hasUserInteracted: Bool
    @Binding var initialLoadComplete: Bool
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(posts) { post in
                    FartPostView(
                        post: post,
                        isPlaying: shouldPlayVideo(for: post),
                        videoCacheManager: videoCacheManager
                    )
                    .id(post.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrollPosition)
        .scrollTargetBehavior(.paging)
        .ignoresSafeArea()
        .refreshable {
            await onRefresh()
        }
        .onChange(of: scrollPosition) { oldValue, newValue in
            // Mark that user has interacted once scroll position changes
            if oldValue != newValue && oldValue != nil {
                hasUserInteracted = true
            }
            handleScrollPositionChange(newValue)
        }
        .onChange(of: posts.map { $0.id }) { _, newIds in
            handlePostsChange(newIds)
        }
        .onChange(of: scrollToTopTrigger) { _, _ in
            scrollToTop()
        }
        .onAppear {
            // Allow first video to play after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                initialLoadComplete = true
            }
        }
    }
    
    // Helper function to determine if a video should play
    private func shouldPlayVideo(for post: FartPost) -> Bool {
        let isCurrentPost = scrollPosition == post.id
        let isFirstPost = post.id == posts.first?.id
        let canPlayFirstPost = hasUserInteracted || initialLoadComplete
        
        return isCurrentPost && (hasUserInteracted || !isFirstPost || canPlayFirstPost)
    }
    
    private func handleScrollPositionChange(_ newValue: String?) {
        // Preload next videos when scroll position changes
        if let currentPostId = newValue,
           let currentIndex = posts.firstIndex(where: { $0.id == currentPostId }) {
            // Extract video URLs from posts starting from current index
            let videoURLs = Array(posts.suffix(from: currentIndex + 1).prefix(3)).map { $0.audioURL }
            Task {
                await videoCacheManager.preloadVideos(videoURLs)
            }
        }
    }
    
    private func handlePostsChange(_ newIds: [String]) {
        if scrollPosition == nil, let firstId = newIds.first {
            print("🔄 FeedView: Setting initial scroll position to first post: \(firstId)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                scrollPosition = firstId
                print("✅ FeedView: Scroll position set to first post: \(firstId)")
            }
        }
    }
    
    private func scrollToTop() {
        if let firstId = posts.first?.id {
            print("🔄 FeedView: Scrolling to top (first post: \(firstId))")
            // Add a small delay to ensure the view is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.scrollPosition = firstId
                print("✅ FeedView: Scroll position set to first post: \(firstId)")
            }
        }
    }
}

#Preview {
    FeedView(firebaseService: FirebaseService.shared)
}
