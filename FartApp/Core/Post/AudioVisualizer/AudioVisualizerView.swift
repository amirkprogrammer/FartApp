//
//  AudioVisualizerView.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import SwiftUI

struct AudioVisualizerView: View {
    let audioLevels: [Float]
    let isRecording: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0..<50, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.green, .yellow, .red]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(
                        width: 3,
                        height: max(4, CGFloat(audioLevels.count > index ? audioLevels[index] : 0) * 150)
                    )
                    .animation(.easeInOut(duration: 0.1), value: audioLevels)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.black.opacity(0.3))
                .frame(height: 200)
        )
    }
}

#Preview {
    AudioVisualizerView(audioLevels: [1.0, 0.5, 0.2], isRecording: true)
}
