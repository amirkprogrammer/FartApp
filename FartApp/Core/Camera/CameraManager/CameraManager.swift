//
//  CameraManager.swift
//  CameraComponent
//
//  Created by Amir Kabiri on 8/17/25.
//

import Foundation
import AVFoundation

class CameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private var videoOutput: AVCaptureMovieFileOutput?
    private var currentCamera: AVCaptureDevice?
    private var videoInput: AVCaptureDeviceInput?
    private var audioInput: AVCaptureDeviceInput?
    private var recordingDelegate: RecordingDelegate?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: completion)
        default:
            completion(false)
        }
    }
    
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio, completionHandler: completion)
        default:
            completion(false)
        }
    }
    
    private func setupCamera() {
        // Configure session before adding inputs/outputs
        session.beginConfiguration()
        
        session.sessionPreset = .high
        
        // Add video input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: camera) else {
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
            self.videoInput = videoInput
            self.currentCamera = camera
        }
        
        // Add audio input
        guard let microphone = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: microphone) else {
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(audioInput) {
            session.addInput(audioInput)
            self.audioInput = audioInput
        }
        
        // Add video output
        let videoOutput = AVCaptureMovieFileOutput()
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            self.videoOutput = videoOutput
        }
        
        // Commit configuration
        session.commitConfiguration()
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .background).async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    func flipCamera() {
        guard let currentVideoInput = videoInput else { return }
        
        session.beginConfiguration()
        session.removeInput(currentVideoInput)
        
        let newCameraPosition: AVCaptureDevice.Position = currentCamera?.position == .back ? .front : .back
        guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newCameraPosition),
              let newVideoInput = try? AVCaptureDeviceInput(device: newCamera) else {
            session.addInput(currentVideoInput)
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(newVideoInput) {
            session.addInput(newVideoInput)
            self.videoInput = newVideoInput
            self.currentCamera = newCamera
        } else {
            session.addInput(currentVideoInput)
        }
        
        session.commitConfiguration()
    }
    
    func startRecording(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let videoOutput = videoOutput else {
            completion(.failure(CameraError.outputNotFound))
            return
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videoURL = documentsPath.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
        
        recordingDelegate = RecordingDelegate(startCompletion: completion, stopCompletion: nil)
        videoOutput.startRecording(to: videoURL, recordingDelegate: recordingDelegate!)
    }
    
    func stopRecording(completion: @escaping (Result<URL, Error>) -> Void) {
        guard let videoOutput = videoOutput else {
            completion(.failure(CameraError.outputNotFound))
            return
        }
        
        recordingDelegate?.stopCompletion = completion
        
        if videoOutput.isRecording {
            videoOutput.stopRecording()
        }
    }
}
