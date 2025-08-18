//
//  VideoRecorderFeedView.swift
//  CameraComponent
//
//  Created by Amir Kabiri on 8/10/25.
//

import SwiftUI

struct VideoRecorderFeedView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var showingRecorder = false
    @State private var feedPosts: [VideoPost] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                if feedPosts.isEmpty {
                    // Empty State
                    VStack(spacing: 20) {
                        Image(systemName: "video.circle")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray)
                        Text("No videos yet")
                            .font(.title2)
                            .foregroundStyle(.gray)
                        Text("Record your first video to get started!")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Feed
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(feedPosts) { post in
                                VideoFeedCell(post: post)
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
            .navigationTitle("My Feed")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingRecorder = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingRecorder) {
            VideoRecorderView(cameraManager: cameraManager) { videoURL in
                addVideoToFeed(videoURL: videoURL)
            }
        }
    }
    
    private func addVideoToFeed(videoURL: URL) {
        let newPost = VideoPost(
            id: UUID(),
            videoURL: videoURL,
            timestamp: Date(),
            caption: "New video"
        )
    }
}

#Preview {
    VideoRecorderFeedView()
}
