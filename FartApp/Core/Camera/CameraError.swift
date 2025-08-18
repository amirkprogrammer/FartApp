//
//  CameraError.swift
//  CameraComponent
//
//  Created by Amir Kabiri on 8/17/25.
//

import Foundation

enum CameraError: LocalizedError {
    case outputNotFound
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .outputNotFound:
            return "Camera output not found"
        case .saveFailed:
            return "Failed to save video"
        }
    }
}
