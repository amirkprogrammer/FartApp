import Foundation
import AVFoundation
import UIKit

class VideoCacheManager: ObservableObject {
    static let shared = VideoCacheManager()
    
    private let cache = NSCache<NSString, CachedVideo>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let maxCacheSize: Int = 500 * 1024 * 1024 // 500MB
    private let preloadCount = 3 // Number of videos to preload
    
    @Published var isLoadingVideo: [String: Bool] = [:]
    @Published var cachedVideos: Set<String> = []
    
    private init() {
        // Create cache directory
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("VideoCache")
        
        do {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        } catch {
            print("❌ VideoCacheManager: Failed to create cache directory: \(error)")
        }
        
        // Load existing cached videos
        loadCachedVideos()
        
        // Set cache limits
        cache.countLimit = 20
        cache.totalCostLimit = maxCacheSize
        
        print("✅ VideoCacheManager: Initialized with cache directory: \(cacheDirectory.path)")
    }
    
    // MARK: - Public Methods
    
    func getVideoURL(for videoURL: String) async -> URL? {
        let videoId = extractVideoId(from: videoURL)
        
        // Check if already cached
        if let cachedURL = getCachedVideoURL(for: videoId) {
            print("✅ VideoCacheManager: Using cached video for: \(videoId)")
            return cachedURL
        }
        
        // Download and cache
        return await downloadAndCacheVideo(from: videoURL, videoId: videoId)
    }
    
    func preloadVideos(_ videoURLs: [String]) async {
        print("🔄 VideoCacheManager: Starting preload for \(videoURLs.count) videos")
        
        // Preload next few videos
        let videosToPreload = Array(videoURLs.prefix(preloadCount))
        
        await withTaskGroup(of: Void.self) { group in
            for videoURL in videosToPreload {
                group.addTask {
                    let videoId = self.extractVideoId(from: videoURL)
                    if !self.isVideoCached(videoId) {
                        await self.downloadAndCacheVideo(from: videoURL, videoId: videoId)
                    }
                }
            }
        }
        
        print("✅ VideoCacheManager: Preload completed")
    }
    
    func clearCache() {
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for fileURL in contents {
                try fileManager.removeItem(at: fileURL)
            }
            cache.removeAllObjects()
            cachedVideos.removeAll()
            print("✅ VideoCacheManager: Cache cleared")
        } catch {
            print("❌ VideoCacheManager: Failed to clear cache: \(error)")
        }
    }
    
    func getCacheSize() -> Int {
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
            return contents.reduce(0) { total, fileURL in
                let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                return total + fileSize
            }
        } catch {
            return 0
        }
    }
    
    // MARK: - Private Methods
    
    private func extractVideoId(from url: String) -> String {
        // Extract a unique identifier from the URL
        if let url = URL(string: url) {
            return url.lastPathComponent.isEmpty ? url.absoluteString.md5 : url.lastPathComponent
        }
        return url.md5
    }
    
    private func isVideoCached(_ videoId: String) -> Bool {
        let cachedURL = getCachedVideoURL(for: videoId)
        return cachedURL != nil && fileManager.fileExists(atPath: cachedURL!.path)
    }
    
    private func getCachedVideoURL(for videoId: String) -> URL? {
        return cacheDirectory.appendingPathComponent("\(videoId).mp4")
    }
    
    private func downloadAndCacheVideo(from videoURL: String, videoId: String) async -> URL? {
        guard let url = URL(string: videoURL) else {
            print("❌ VideoCacheManager: Invalid URL: \(videoURL)")
            return nil
        }
        
        // Check if already being downloaded
        if isLoadingVideo[videoId] == true {
            print("🔄 VideoCacheManager: Video already being downloaded: \(videoId)")
            return nil
        }
        
        await MainActor.run {
            isLoadingVideo[videoId] = true
        }
        
        defer {
            Task { @MainActor in
                isLoadingVideo[videoId] = false
            }
        }
        
        do {
            print("🔄 VideoCacheManager: Downloading video: \(videoId)")
            
            // Download video data
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Save to cache
            let cachedURL = getCachedVideoURL(for: videoId)!
            try data.write(to: cachedURL)
            
            // Update cache tracking
            await MainActor.run {
                cachedVideos.insert(videoId)
            }
            
            // Manage cache size
            await manageCacheSize()
            
            print("✅ VideoCacheManager: Successfully cached video: \(videoId)")
            return cachedURL
            
        } catch {
            print("❌ VideoCacheManager: Failed to download video \(videoId): \(error)")
            return nil
        }
    }
    
    private func manageCacheSize() async {
        let currentSize = getCacheSize()
        
        if currentSize > maxCacheSize {
            print("🔄 VideoCacheManager: Cache size (\(currentSize)) exceeds limit (\(maxCacheSize)), cleaning up...")
            
            do {
                let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.creationDateKey, .fileSizeKey])
                
                // Sort by creation date (oldest first)
                let sortedFiles = contents.sorted { file1, file2 in
                    let date1 = (try? file1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                    let date2 = (try? file2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                    return date1 < date2
                }
                
                // Remove oldest files until under limit
                var sizeToRemove = currentSize - (maxCacheSize * 3 / 4) // Remove to 75% of limit
                
                for fileURL in sortedFiles {
                    if sizeToRemove <= 0 { break }
                    
                    let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                    try fileManager.removeItem(at: fileURL)
                    sizeToRemove -= fileSize
                    
                    let videoId = fileURL.deletingPathExtension().lastPathComponent
                    await MainActor.run {
                        cachedVideos.remove(videoId)
                    }
                }
                
                print("✅ VideoCacheManager: Cache cleanup completed")
                
            } catch {
                print("❌ VideoCacheManager: Failed to cleanup cache: \(error)")
            }
        }
    }
    
    private func loadCachedVideos() {
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for fileURL in contents {
                let videoId = fileURL.deletingPathExtension().lastPathComponent
                cachedVideos.insert(videoId)
            }
            print("✅ VideoCacheManager: Loaded \(cachedVideos.count) cached videos")
        } catch {
            print("❌ VideoCacheManager: Failed to load cached videos: \(error)")
        }
    }
}

// MARK: - CachedVideo Model

class CachedVideo {
    let url: URL
    let data: Data
    let timestamp: Date
    
    init(url: URL, data: Data) {
        self.url = url
        self.data = data
        self.timestamp = Date()
    }
}

// MARK: - String Extension for MD5

extension String {
    var md5: String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        _ = data.withUnsafeBytes {
            CC_MD5($0.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}

// MARK: - CommonCrypto Import

import CommonCrypto
