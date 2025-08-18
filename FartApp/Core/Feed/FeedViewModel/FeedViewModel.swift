//
//  FeedViewModel.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/8/25.
//

import Foundation

class FeedViewModel: ObservableObject {
    @Published var posts: [FartPost] = []
    
    func loadPosts() {
        // mock data
        posts = [
            DeveloperPreview.shared.fartPost
        ]
    }
}
