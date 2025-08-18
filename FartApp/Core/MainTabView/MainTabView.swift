//
//  MainTabView.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/7/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            DiscoverView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Discover")
                }
                .tag(1)
            
//            RecordView()
            VideoRecorderFeedView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Record")
                }
                .tag(2)
            
            NotificationsView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Activity")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(.green)
    }
}

#Preview {
    MainTabView()
}
