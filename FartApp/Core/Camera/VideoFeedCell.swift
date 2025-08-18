//
//  VideoFeedCell.swift
//  CameraComponent
//
//  Created by Amir Kabiri on 8/17/25.
//

import SwiftUI

struct VideoFeedCell: View {
    let post: VideoPost
    @State private var showingVideoPlayer = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Video thumbnail/player
            Button(action: {
                showingVideoPlayer = true
            }) {
                VideoThumbnailView(videoURL: post.videoURL)
                    .frame(height: 200)
                    .cornerRadius(12)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.caption)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(RelativeDateTimeFormatter().localizedString(for: post.timestamp, relativeTo: Date()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    shareVideo()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 4)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .fullScreenCover(isPresented: $showingVideoPlayer) {
            VideoPlayerView(videoURL: post.videoURL)
        }
    }
    
    private func shareVideo() {
        let activityController = UIActivityViewController(activityItems: [post.videoURL], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityController, animated: true)
        }
    }
}
