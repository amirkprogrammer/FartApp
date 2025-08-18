//
//  VideoPlayerView.swift
//  CameraComponent
//
//  Created by Amir Kabiri on 8/17/25.
//

import SwiftUI
import AVFoundation
import AVKit

struct VideoPlayerView: View {
    let videoURL: URL
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VideoPlayer(player: AVPlayer(url: videoURL))
                .onAppear {
                    // Auto-play the video
                    let player = AVPlayer(url: videoURL)
                    player.play()
                }
            
            VStack {
                HStack {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
    }
}
