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

struct ProfileErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.red)
            
            Text("Error")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct ProfileEmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 50))
                .foregroundStyle(.gray)
            
            Text("No Profile Data")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Unable to load profile information.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
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
