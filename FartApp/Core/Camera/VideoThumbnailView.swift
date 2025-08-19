//
//  VideoThumbnailView.swift
//  CameraComponent
//
//  Created by Amir Kabiri on 8/17/25.
//

import SwiftUI
import AVFoundation

struct VideoThumbnailView: View {
    let videoURL: URL
    @State private var thumbnail: UIImage?
    
    var body: some View {
        ZStack {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.gray.opacity(0.3)
            }
            
            // Play button overlay
            VStack {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5)
                Text("Tap to play")
                    .foregroundColor(.white)
                    .font(.caption)
                    .shadow(color: .black.opacity(0.3), radius: 2)
            }
        }
        .onAppear {
            generateThumbnail()
        }
    }
    
    private func generateThumbnail() {
        let asset = AVURLAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        
        DispatchQueue.global(qos: .background).async {
            imageGenerator.generateCGImageAsynchronously(for: time) { cgImage, actualTime, error in
                if let error = error {
                    print("Error generating thumbnail: \(error)")
                    return
                }
                
                guard let cgImage = cgImage else {
                    print("No thumbnail generated")
                    return
                }
                
                let uiImage = UIImage(cgImage: cgImage)
                
                DispatchQueue.main.async {
                    self.thumbnail = uiImage
                }
            }
        }
    }
}
