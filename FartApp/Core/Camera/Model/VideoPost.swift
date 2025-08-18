//
//  VideoPost.swift
//  CameraComponent
//
//  Created by Amir Kabiri on 8/17/25.
//

import Foundation

struct VideoPost: Identifiable {
    let id: UUID
    let videoURL: URL
    let timestamp: Date
    let caption: String
}
