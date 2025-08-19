//
//  FartPostView.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/8/25.
//

import SwiftUI
import AVKit

struct FartPostView: View {
    let post: FartPost
    let isPlaying: Bool
    let videoCacheManager: VideoCacheManager
    
    @StateObject private var audioPlayer = AudioPlayerViewModel()
    @State private var showComments = false
    @State private var player: AVPlayer?
    @State private var isLoadingVideo = false
    
    var body: some View {
        ZStack {
            // Video background
            if let videoURL = URL(string: post.audioURL) {
                ZStack {
                    if isLoadingVideo {
                        // Loading indicator
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            Text("Loading video...")
                                .foregroundColor(.white)
                                .font(.caption)
                                .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.7))
                    } else {
                        if let player = player {
                            // Use standard VideoPlayer
                            VideoPlayer(player: player)
                                .onAppear {
                                    print("🔄 FartPostView: VideoPlayer appeared for post \(post.id)")
                                }
                                .onDisappear {
                                    print("🔄 FartPostView: VideoPlayer disappeared for post \(post.id)")
                                }
                                .allowsHitTesting(false)
                        } else {
                            // Show loading state if player is not ready
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                                Text("Preparing video...")
                                    .foregroundColor(.white)
                                    .font(.caption)
                                    .padding(.top, 8)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.7))
                        }
                    }
                }
                .onAppear {
                    loadVideo()
                }
                .onChange(of: isPlaying) { _, playing in
                    print("🔄 FartPostView: isPlaying changed to \(playing) for post \(post.id)")
                    if playing {
                        // If player is not ready yet, wait for it to be loaded
                        if player == nil {
                            print("🔄 FartPostView: Player not ready yet, will play when loaded")
                            // The player will be set to play in loadVideo() when isPlaying is true
                        } else {
                            player?.play()
                        }
                    } else {
                        player?.pause()
                    }
                }
                .onDisappear {
                    player?.pause()
                    player = nil
                }
            } else {
                // Fallback background if no video URL
                LinearGradient(
                    gradient: Gradient(colors: [.green.opacity(0.3), .brown.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            
            VStack {
                Spacer()
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        // User info
                        HStack {
                            AsyncImage(url: URL(string: post.userAvatar)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle()
                                    .fill(.gray.opacity(0.3))
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(.circle)
                            
                            VStack(alignment: .leading) {
                                Text(post.username)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text("@\(post.username)")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                        }
                        
                        // Caption
                        Text(post.caption)
                            .font(.body)
                            .foregroundStyle(.white)
                            .lineLimit(3)
                        
                        // Tags
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(post.tags, id: \.self) { tag in
                                    TagView(tag: tag)
                                }
                            }
                        }
                        
                        // Audio analysis
                        HStack {
                            IntensityMeter(level: post.intensity)
                            Spacer()
                            Text(post.classification.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        // Play/pause button (now controls video)
                        Button {
                            if isPlaying {
                                player?.pause()
                            } else {
                                player?.play()
                            }
                        } label: {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(.white)
                                .background {
                                    Circle()
                                        .fill(.green.opacity(0.8))
                                        .frame(width: 50, height: 50)
                                }
                                .shadow(color: .black, radius: 3)
                        }
                        .padding(.bottom, 10)
                        
                        // Like button
                        Button {
                            // Handle like
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                    .font(.system(size: 24))
                                    .foregroundStyle(post.isLiked ? .red : .white)
                                Text("\(post.whiffCount)")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                            }
                        }
                        
                        // Comment button
                        Button {
                            showComments = true
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "bubble.right")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white)
                                Text("\(post.commentCount)")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                            }
                        }
                        
                        // Share button
                        Button {
                            // Handle share
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white)
                                Text("\(post.shareCount)")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal)
                .padding(.bottom, 120)
            }
        }
        .containerRelativeFrame(.vertical)
        .sheet(isPresented: $showComments) {
            CommentsView(post: post)
        }
    }
    
    private func loadVideo() {
        print("🔄 FartPostView: Loading video for post \(post.id), isPlaying: \(isPlaying)")
        print("🔄 FartPostView: Video URL: \(post.audioURL)")
        
        // Test if the URL is valid
        guard let url = URL(string: post.audioURL) else {
            print("❌ FartPostView: Invalid URL: \(post.audioURL)")
            isLoadingVideo = false
            return
        }
        
        print("🔄 FartPostView: Valid URL created: \(url)")
        
        // Simple URL validation
        print("🔄 FartPostView: Testing URL accessibility for: \(url)")
        
        isLoadingVideo = true
        
        Task {
            if let cachedURL = await videoCacheManager.getVideoURL(for: post.audioURL) {
                await MainActor.run {
                    print("🔄 FartPostView: Creating AVPlayer with cached URL: \(cachedURL)")
                    player = AVPlayer(url: cachedURL)
                    
                    // Configure player for better playback
                    player?.automaticallyWaitsToMinimizeStalling = true
                    player?.allowsExternalPlayback = false
                    
                    // Ensure the player recognizes this as video content
                    if let currentItem = player?.currentItem {
                        // Set video composition to ensure it's treated as video
                        currentItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
                        
                        // Force unmute the player
                        player?.isMuted = false
                    }
                    
                    print("✅ FartPostView: Video loaded for post \(post.id)")
                    isLoadingVideo = false
                    
                    // Wait for player to be ready before playing
                    if isPlaying {
                        print("🔄 FartPostView: Auto-playing video for post \(post.id)")
                        // Wait for player item to be ready
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if self.isPlaying {
                                print("🔄 FartPostView: Playing video after delay for post \(post.id)")
                                self.player?.play()
                            }
                        }
                    }
                }
            } else {
                print("❌ FartPostView: Failed to load video for post \(post.id)")
                await MainActor.run {
                    isLoadingVideo = false
                }
            }
        }
    }
    

}

// MARK: - Custom Video Player View

struct AVPlayerLayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
        
        // Ensure the player layer updates when the view bounds change
        view.layer.setNeedsLayout()
        view.layer.layoutIfNeeded()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let playerLayer = uiView.layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.frame = uiView.bounds
        }
    }
}

#Preview {
    FartPostView(post: DeveloperPreview.shared.fartPost, isPlaying: false, videoCacheManager: VideoCacheManager.shared)
}
