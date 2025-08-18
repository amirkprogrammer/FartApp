//
//  AudioRecorderViewModel.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import Foundation
import AVFoundation

class AudioRecorderViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var hasRecording = false
    @Published var currentDuration: TimeInterval = 0
    @Published var audioLevels: [Float] = Array(repeating: 0, count: 50)
    @Published var recordingURL: URL?
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    
    func startRecording() {
        isRecording = true
        //Implement actual recording logic
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.currentDuration += 0.1
            self.updateAudioLevels()
        }
    }
    
    func stopRecording() {
        isRecording = false
        hasRecording = true
        timer?.invalidate()
        // Stop actual recording
    }
    
    func deleteRecording() {
        hasRecording = false
        currentDuration = 0
        recordingURL = nil
        audioLevels = Array(repeating: 0, count: 50)
    }
    
    func playRecording() {
        // Implement playback
    }
    
    func updateAudioLevels() {
        audioLevels = (0..<50).map { _ in Float.random(in: 0...1) }
    }
}
