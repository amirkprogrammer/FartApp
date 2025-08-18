//
//  FartPostView.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/8/25.
//

import SwiftUI

struct FartPostView: View {
    let post: FartPost
    let geometry: GeometryProxy
    let isPlaying: Bool
    
    @StateObject private var audioPlayer = AudioPlayerViewModel()
    @State private var showComments = false
    
    var body: some View {
        ZStack {
            // bg gradient
            LinearGradient(
                gradient: Gradient(colors: [.green.opacity(0.3), .brown.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack {
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        // user info
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
                            
                            Text("@\(post.username)")
                                .foregroundStyle(.white)
                                .font(.headline)
                        }
                        
                        // caption
                        Text(post.caption)
                            .foregroundStyle(.white)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                        
                        // tags
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(post.tags, id: \.self) { tag in
                                        TagView(tag: tag)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        
                        // audio analysis info
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Analysis:")
                                .foregroundStyle(.white.opacity(0.8))
                                .font(.caption)
                            
                            HStack {
                                IntensityMeter(level: post.intensity)
                                Text("\(post.classification.rawValue)")
                                    .foregroundStyle(.yellow)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // action buttons
                    VStack(spacing: 20) {
                        // play/pause button
                        Button {
                            audioPlayer.togglePlayback(url: post.audioURL)
                        } label: {
                            Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(.white)
                                .background {
                                    Circle()
                                        .fill(.green.opacity(0.8))
                                        .frame(width: 50, height: 50)
                                }
                        }
                        
                        // like button
                        VStack {
                            Button {
                                // toggle like
                            } label: {
                                Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                    .font(.system(size: 25))
                                    .foregroundStyle(post.isLiked ? .red : .white)
                            }
                            Text("\(post.whiffCount)")
                                .foregroundStyle(.white)
                                .font(.caption)
                        }
                        
                        // comment button
                        VStack {
                            Button {
                                showComments = true
                            } label: {
                                Image(systemName: "bubble.left")
                                    .font(.system(size: 25))
                                    .foregroundStyle(.white)
                            }
                            
                            Text("\(post.commentCount)")
                                .foregroundStyle(.white)
                                .font(.caption)
                        }
                        
                        // share button
                        VStack {
                            Button {
                                // share functionality
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 25))
                                    .foregroundStyle(.white)
                            }
                            Text("\(post.shareCount)")
                                .foregroundStyle(.white)
                                .font(.caption)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            
            // audio visualization overlay
            if audioPlayer.isPlaying {
                AudioVisualizerOverlay(audioLevels: audioPlayer.audioLevels)
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .sheet(isPresented: $showComments) {
            CommentsView(post: post)
        }
        .onChange(of: isPlaying) { playing in
            if !playing {
                audioPlayer.stop()
            }
        }
    }
}

#Preview {
   GeometryReader { geometry in
        FartPostView(post: DeveloperPreview.shared.fartPost, geometry: geometry, isPlaying: false)
    }
}
