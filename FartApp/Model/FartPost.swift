//
//  FartPost.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/16/25.
//

import Foundation

struct FartPost: Identifiable, Codable {
    var id = UUID()
    let userId: String
    let username: String
    let userAvatar: String
    let audioURL: URL?
    let videoURL: URL?
    let caption: String
    let tags: [FartTag]
    let createdAt: Date
    let duration: Double
    let intensity: Int
    let whiffCount: Int
    let commentCount: Int
    let shareCount: Int
    var isLiked: Bool = false
    
    // Audio analysis results
    let volumeLevel: Double
    let dominantFrequency: Double
    let classification: FartClassification
}

enum FartTag: String, CaseIterable, Codable {
    case squeaky = "Squeaky"
    case explosive = "Explosive"
    case wet = "Wet"
    case silentButDeadly = "Silent-But-Deadly"
    case trumpet = "Trumpet"
    case machineGun = "Machine Gun"
    case gentleBreeze = "Gentle Breeze"
    case hurricane = "Hurricane"
    case ninja = "Ninja"
    case announcement = "Full Announcement"
    
    var emoji: String {
        switch self {
        case .squeaky: return "🎺"
        case .explosive: return "💥"
        case .wet: return "💧"
        case .silentButDeadly: return "🥷"
        case .trumpet: return "📯"
        case .machineGun: return "🔫"
        case .gentleBreeze: return "🍃"
        case .hurricane: return "🌀"
        case .ninja: return "👤"
        case .announcement: return "📢"
        }
    }
}

enum FartClassification: String, Codable {
    case classic = "Classic"
    case legendary = "Legendary"
    case epic = "Epic"
    case sneaky = "Sneaky"
    case thunderous = "Thunderous"
}
