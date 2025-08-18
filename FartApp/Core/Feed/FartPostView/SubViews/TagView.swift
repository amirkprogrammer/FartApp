//
//  TagView.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import SwiftUI

struct TagView: View {
    let tag: FartTag
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag.emoji)
                .font(.caption)
            Text(tag.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.2))
        )
        .foregroundColor(.white)
    }
}


#Preview {
    TagView(tag: .explosive)
}
