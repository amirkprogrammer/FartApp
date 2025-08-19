//
//  ContentView.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/7/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    
    var body: some View {
        Group {
            // Re-enable authentication for Firebase testing
            if firebaseService.isAuthenticated {
                MainTabView(firebaseService: firebaseService)
                    .onAppear {
                        print("🔄 ContentView: Showing MainTabView (user is authenticated)")
                    }
            } else {
                LoginView()
                    .onAppear {
                        print("🔄 ContentView: Showing LoginView (user is NOT authenticated)")
                    }
            }
            
            // Temporarily bypass authentication for testing (commented out)
            /*
            MainTabView()
                .onAppear {
                    print("🔄 ContentView: Showing MainTabView (temporarily bypassing auth)")
                }
            */
        }
        .onAppear {
            print("🔄 ContentView: onAppear - isAuthenticated: \(firebaseService.isAuthenticated)")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(FirebaseService.shared)
}
