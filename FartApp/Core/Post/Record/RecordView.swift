//
//  RecordView.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/16/25.
//

import SwiftUI

struct RecordView: View {
    @StateObject private var recorder = AudioRecorderViewModel()
    @State private var selectedTags: Set<FartTag> = []
    @State private var caption = ""
    @State private var showTagSelection = false
    
    var body: some View {
        ZStack {
            // BG
            LinearGradient(
                gradient: Gradient(colors: [.black, .green.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Title
                Text("Create Your Masterpiece")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.top, 50)
                
                Spacer()
                
                // Audio visualization
                AudioVisualizerView(
                    audioLevels: recorder.audioLevels,
                    isRecording: recorder.isRecording
                )
                .frame(height: 200)
                .padding(.horizontal)
                
                // Recording info
                if recorder.isRecording {
                    VStack {
                        Text("Recording...")
                            .foregroundStyle(.red)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(String(format: "%.1fs", recorder.currentDuration))
                            .foregroundStyle(.white)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                } else if recorder.hasRecording {
                    VStack {
                        Text("Recording Complete!")
                            .foregroundStyle(.green)
                            .font(.headline)
                        
                        HStack {
                            Button("Play") {
                                recorder.playRecording()
                            }
                            .foregroundStyle(.blue)
                            
                            Button("Re-record") {
                                recorder.deleteRecording()
                            }
                            .foregroundStyle(.red)
                        }
                        .font(.subheadline)
                    }
                }
                
                // Main record button
                RecordButton(
                    isRecording: recorder.isRecording,
                    hasRecording: recorder.hasRecording) {
                        if recorder.isRecording {
                            recorder.stopRecording()
                        } else if recorder.hasRecording {
                            // Show upload options
                            showTagSelection = true
                        } else {
                            recorder.startRecording()
                        }
                    }
                
                Spacer()
                
                // Instructions
                Text(recorder.isRecording ? "Tap to stop" :
                        recorder.hasRecording ? "Tap to post" : "Hold to record")
                .foregroundStyle(.white.opacity(0.7))
                .font(.subheadline)
                .padding(.bottom, 50)
            }
        }
        .sheet(isPresented: $showTagSelection) {
            PostCreationSheet(
                audioURL: recorder.recordingURL,
                selectedTags: $selectedTags,
                caption: $caption) { tags, caption in
                    // Handle posting
                    recorder.deleteRecording()
                    showTagSelection = false
                }
        }
    }
}

#Preview {
    RecordView()
}
