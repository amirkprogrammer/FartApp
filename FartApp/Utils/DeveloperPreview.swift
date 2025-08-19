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
		id: UUID(),
		userId: "1",
		username: "gassy_greg",
		userAvatar: "",
		audioURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
		caption: "Gassy Glory!",
		tags: [.explosive, .announcement],
		intensity: 4,
		classification: .epic,
		whiffCount: 234,
		commentCount: 45,
		shareCount: 12,
		isLiked: false,
		timestamp: Date()
	)
}
