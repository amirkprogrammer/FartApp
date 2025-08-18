//
//  AchievementBadge.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import SwiftUI

struct AchievementBadge: View {
    let achievement: String
    
    var body: some View {
        VStack {
            Text("🏆")
                .font(.title)
            Text(achievement)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.yellow.opacity(0.2))
        )
    }
}

#Preview {
    AchievementBadge(achievement: "")
}
