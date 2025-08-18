//
//  AudioPlayerViewModel.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import Foundation

class AudioPlayerViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var audioLevels: [Float] = Array(repeating: 0, count: 30)
    
    func togglePlayback(url: URL?) {
        isPlaying.toggle()
        if isPlaying {
            startVisualization()
        }
    }
    
    func stop() {
        isPlaying = false
    }
    
    private func startVisualization() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.isPlaying {
                self.audioLevels = (0..<30).map { _ in Float.random(in: 0...1) }
            } else {
                timer.invalidate()
                self.audioLevels = Array(repeating: 0, count: 30)
            }
        }
    }
}
