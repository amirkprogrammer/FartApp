//
//  VideoRecorderView.swift
//  CameraComponent
//
//  Created by Amir Kabiri on 8/11/25.
//

import SwiftUI
import AVFoundation
import Photos
import AVKit

struct VideoRecorderView: View {
    @StateObject var cameraManager: CameraManager
    @State private var isRecording = false
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSuccess = false
    @Environment(\.dismiss) private var dismiss
    
    let onVideoRecorded: (URL) -> Void
    
    var body: some View {
        ZStack {
            // Camera Preview
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
            
            VStack {
                // Top bar
                HStack {
                    Button("Cancel") {
                        if isRecording {
                            stopRecording()
                        }
                        dismiss()
                    }
                    .foregroundStyle(.white)
                    .padding()
                    
                    Spacer()
                    
                    if isRecording {
                        HStack {
                            Circle()
                                .fill(.red)
                                .frame(width: 12, height: 12)
                                .opacity(0.8)
                            
                            Text(timeString(from: recordingTime))
                                .foregroundStyle(.white)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding()
                    }
                }
                
                Spacer()
                
                // Recording controls
                HStack(spacing: 50) {
                    // Flip camera button
                    Button {
                        cameraManager.flipCamera()
                    } label: {
                        Image(systemName: "camera.rotate")
                            .font(.title)
                            .foregroundStyle(.white)
                            .frame(width: 50, height: 50)
                            .background(.black.opacity(0.3))
                            .clipShape(.circle)
                    }
                    .disabled(isRecording)
                    
                    // Record button
                    Button {
                        if isRecording {
                            stopRecording()
                        } else {
                            startRecording()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 80, height: 80)
                            
                            if isRecording {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.red)
                                    .frame(width: 30, height: 30)
                            } else {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 70, height: 70)
                            }
                        }
                    }

                        // Placeholder for symmetry
                    Color.clear
                        .frame(width: 50, height: 50)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            requestPermissions()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .overlay {
            if showingSuccess {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                    Text("Video Saved!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black.opacity(0.8))
                .transition(.opacity)
            }
        }
    }
    
    @MainActor
    private func requestPermissions() {
        cameraManager.requestCameraPermission { granted in
            if granted {
                self.cameraManager.requestMicrophonePermission { audioGranted in
                    if audioGranted {
                        // Small delay to ensure UI is ready
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.cameraManager.startSession()
                        }
                    } else {
                        self.alertMessage = "Microphone access is required to record videos with audio"
                        self.showingAlert = true
                    }
                }
            }
        }
    }
    
    @MainActor
    private func startRecording() {
        cameraManager.startRecording { result in
            switch result {
            case .success:
                isRecording = true
                startTimer()
            case .failure(let error):
                alertMessage = error.localizedDescription
                showingAlert = true
            }
        }
    }
    
    @MainActor
    private func stopRecording() {
        cameraManager.stopRecording { result in
                isRecording = false
                stopTimer()
            
            switch result {
            case .success(let url):
                onVideoRecorded(url)
                showingSuccess = true
                // Automatically dismiss after successful recording
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    dismiss()
                }
            case .failure(let error):
                alertMessage = error.localizedDescription
                showingAlert = true
            }
        }
    }
    
    private func startTimer() {
        recordingTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            recordingTime += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        recordingTime = 0
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    VideoRecorderView(cameraManager: CameraManager()) { url in
        
    }
}
