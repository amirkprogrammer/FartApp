//
//  FartAppApp.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/7/25.
//

import SwiftUI
import FirebaseCore

@main
struct FartAppApp: App {
    init() {
        print("🔄 FartAppApp: Initializing...")
        FirebaseApp.configure()
        print("✅ FartAppApp: Firebase configured")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(FirebaseService.shared)
                .onAppear {
                    print("🔄 FartAppApp: ContentView appeared")
                }
        }
    }
}
