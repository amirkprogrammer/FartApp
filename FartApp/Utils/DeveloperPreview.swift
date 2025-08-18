//
//  DeveloperPreview.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/8/25.
//

import Foundation

struct DeveloperPreview {
    static let shared = DeveloperPreview()
    
    let fartPost = FartPost(
        userId: "1",
        username: "gassy_greg",
        userAvatar: "",
        audioURL: nil,
        videoURL: nil,
        caption: "Gassy Glory!",
        tags: [.explosive, .announcement],
        createdAt: Date(),
        duration: 2.5,
        intensity: 4,
        whiffCount: 234,
        commentCount: 45,
        shareCount: 12,
        volumeLevel: 0.8,
        dominantFrequency: 200.0,
        classification: .epic
    )
}
