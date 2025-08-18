//
//  PostCreationSheet.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import SwiftUI

struct PostCreationSheet: View {
    let audioURL: URL?
    @Binding var selectedTags: Set<FartTag>
    @Binding var caption: String
    let onPost: (Set<FartTag>, String) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Add the finishing touches")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                // Caption input
                VStack(alignment: .leading) {
                    Text("Caption")
                        .font(.headline)
                    
                    TextField("Describe your masterpiece...", text: $caption, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3)
                }
                .padding(.horizontal)
                
                // Tag selection
                VStack(alignment: .leading) {
                    Text("Tags")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
                        ForEach(FartTag.allCases, id: \.self) { tag in
                            TagSelectionButton(
                                tag: tag,
                                isSelected: selectedTags.contains(tag)) {
                                    if selectedTags.contains(tag) {
                                        selectedTags.remove(tag)
                                    } else {
                                        selectedTags.insert(tag)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Post button
                Button("Post Your Fart") {
                    onPost(selectedTags, caption)
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.green)
                )
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
        }
    }
}

#Preview {
    PostCreationSheet(audioURL: nil, selectedTags: .constant(Set<FartTag>()), caption: .constant("")) { _ , _ in
        
    }
}
