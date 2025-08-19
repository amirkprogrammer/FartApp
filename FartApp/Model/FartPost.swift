//
//  FartPost.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/16/25.
//

import Foundation

struct FartPost: Identifiable, Codable {
    var id: String = UUID().uuidString
    let userId: String
    let username: String
    let userAvatar: String
    let audioURL: String
    let caption: String
    let tags: [FartTag]
    let timestamp: Date
    let intensity: Int
    var whiffCount: Int
    let commentCount: Int
    let shareCount: Int
    var isLiked: Bool = false
    
    // Audio analysis results
    let classification: FartClassification
    
    init(id: UUID = UUID(), userId: String, username: String, userAvatar: String, audioURL: String, caption: String, tags: [FartTag], intensity: Int, classification: FartClassification, whiffCount: Int, commentCount: Int, shareCount: Int, isLiked: Bool, timestamp: Date) {
        self.id = id.uuidString
        self.userId = userId
        self.username = username
        self.userAvatar = userAvatar
        self.audioURL = audioURL
        self.caption = caption
        self.tags = tags
        self.timestamp = timestamp
        self.intensity = intensity
        self.whiffCount = whiffCount
        self.commentCount = commentCount
        self.shareCount = shareCount
        self.isLiked = isLiked
        self.classification = classification
    }
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

enum FartClassification: String, Codable, CaseIterable {
    case classic = "Classic"
    case legendary = "Legendary"
    case epic = "Epic"
    case sneaky = "Sneaky"
    case thunderous = "Thunderous"
    case normal = "Normal"
}

// MARK: - Notification Names
extension Notification.Name {
    static let scrollToTop = Notification.Name("scrollToTop")
}
