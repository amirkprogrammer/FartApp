//
//  PlaceholderViews.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import SwiftUI

// MARK: - Placeholder Views
struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading farts...")
                .foregroundColor(.white)
                .padding(.top)
        }
    }
}

struct NotificationsView: View {
    var body: some View {
        NavigationView {
            Text("Your fart notifications")
                .navigationTitle("Activity")
        }
    }
}

struct CommentsView: View {
    let post: FartPost
    
    var body: some View {
        NavigationView {
            Text("Comments for this fart")
                .navigationTitle("Comments")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
