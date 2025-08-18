//
//  RecordButton.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import SwiftUI

struct RecordButton: View {
    let isRecording: Bool
    let hasRecording: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isRecording ? .red : hasRecording ? .green : .white)
                    .frame(width: 80, height: 80)
                if isRecording {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white)
                        .frame(width: 30, height: 30)
                } else if hasRecording {
                    Image(systemName: "checkmark")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Circle()
                        .fill(.red)
                        .frame(width: 60, height: 60)
                }
            }
            .scaleEffect(isRecording ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isRecording)
        }
    }
}

#Preview {
    RecordButton(isRecording: false, hasRecording: true) {
        
    }
}
