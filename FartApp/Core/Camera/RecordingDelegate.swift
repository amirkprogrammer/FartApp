//
//  RecordingDelegate.swift
//  CameraComponent
//
//  Created by Amir Kabiri on 8/17/25.
//

import Foundation
import AVFoundation
import Photos

class RecordingDelegate: NSObject, AVCaptureFileOutputRecordingDelegate {
    private let startCompletion: (Result<Void, Error>) -> Void
    var stopCompletion: ((Result<URL, Error>) -> Void)?
    
    init(startCompletion: @escaping (Result<Void, Error>) -> Void, stopCompletion: ((Result<URL, Error>) -> Void)?) {
        self.startCompletion = startCompletion
        self.stopCompletion = stopCompletion
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.startCompletion(.success(()))
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                self.stopCompletion?(.failure(error))
            } else {
                // Save to photo library
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                    if status == .authorized {
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                        }) { success, error in
                            DispatchQueue.main.async {
                                if success {
                                    self.stopCompletion?(.success(outputFileURL))
                                } else if let error = error {
                                    self.stopCompletion?(.failure(error))
                                } else {
                                    self.stopCompletion?(.failure(CameraError.saveFailed))
                                }
                            }
                        }
                    } else {
                        // Even if we can't save to photo library, we can still use the video in the app
                        DispatchQueue.main.async {
                            self.stopCompletion?(.success(outputFileURL))
                        }
                    }
                }
            }
        }
    }
}
