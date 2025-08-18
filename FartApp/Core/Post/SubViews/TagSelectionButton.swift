//
//  TagSelectionButton.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import SwiftUI

struct TagSelectionButton: View {
    let tag: FartTag
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(tag.emoji)
                Text(tag.rawValue)
                    .font(.subheadline)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
            )
            .foregroundColor(.primary)
        }
    }
}

#Preview {
    TagSelectionButton(tag: .announcement, isSelected: true) {
        
    }
}
