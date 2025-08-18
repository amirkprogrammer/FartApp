//
//  FeedView.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/8/25.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var currentIndex = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                if viewModel.posts.isEmpty {
                    LoadingView()
                } else {
                    TabView(selection: $currentIndex) {
                        ForEach(Array(viewModel.posts.enumerated()), id: \.element.id) {
                            index,
                            post in
                            FartPostView(
                                post: post,
                                geometry: geometry,
                                isPlaying: index == currentIndex
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
                }
            }
        }
        .onAppear {
            viewModel.loadPosts()
        }
    }
}

#Preview {
    FeedView()
}
