//
//  AudioVisualizerOverlay.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import SwiftUI

struct AudioVisualizerOverlay: View {
    let audioLevels: [Float]
    
    var body: some View {
        VStack {
            Spacer()
            HStack(alignment: .bottom, spacing: 1) {
                ForEach(0..<30, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 1)
                        .fill(.white.opacity(0.8))
                        .frame(
                            width: 2,
                            height: max(2, CGFloat(audioLevels.count > index ? audioLevels[index] : 0) * 50)
                        )
                        .animation(.easeInOut(duration: 0.1), value: audioLevels)
                }
            }
            .padding(.bottom, 200)
            Spacer()
        }
    }
}

#Preview {
    AudioVisualizerOverlay(audioLevels: [1.0, 0.5, 0.2])
}
