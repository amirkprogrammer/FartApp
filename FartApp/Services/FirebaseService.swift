//
//  FirebaseService.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn
import GoogleSignInSwift

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private init() {
        print("🔄 FirebaseService: Initializing...")
        setupAuthStateListener()
        print("✅ FirebaseService: Initialized")
    }
    
    // MARK: - Authentication
    
    private func setupAuthStateListener() {
        print("🔄 FirebaseService: Setting up auth state listener...")
        auth.addStateDidChangeListener { [weak self] _, user in
            print("🔄 FirebaseService: Auth state changed - user: \(user?.uid ?? "nil")")
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                print("✅ FirebaseService: Auth state updated - isAuthenticated: \(self?.isAuthenticated ?? false)")
            }
        }
    }
    
    func signUp(email: String, password: String, username: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let result = try await auth.createUser(withEmail: email, password: password)
        let user = result.user
        
        // Create user profile
        let profile = UserProfile(
            id: user.uid,
            username: username,
            email: email,
            avatarURL: "",
            bio: "",
            followerCount: 0,
            followingCount: 0,
            postCount: 0,
            joinDate: Date()
        )
        
        try await saveUserProfile(profile)
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        _ = try await auth.signIn(withEmail: email, password: password)
    }
    
    // MARK: - Google Sign-In
    
    func signInWithGoogle() async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            throw FirebaseError.presentationError
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw FirebaseError.googleSignInError
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)
        
        let authResult = try await auth.signIn(with: credential)
        let user = authResult.user
        
        // Check if user profile exists, if not create one
        if try await getUserProfile(userId: user.uid) == nil {
            let profile = UserProfile(
                id: user.uid,
                username: user.displayName ?? "User",
                email: user.email ?? "",
                avatarURL: user.photoURL?.absoluteString ?? "",
                bio: "Welcome to FartApp! 💨",
                followerCount: 0,
                followingCount: 0,
                postCount: 0,
                joinDate: Date()
            )
            
            try await saveUserProfile(profile)
        }
    }
    
    func signOut() throws {
        // Sign out from Google
        GIDSignIn.sharedInstance.signOut()
        // Sign out from Firebase
        try auth.signOut()
    }
    
    // MARK: - User Profile
    
    func saveUserProfile(_ profile: UserProfile) async throws {
        let data = try JSONEncoder().encode(profile)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        
        try await db.collection("users").document(profile.id).setData(dict)
    }
    
    func getUserProfile(userId: String) async throws -> UserProfile? {
        let document = try await db.collection("users").document(userId).getDocument()
        
        guard let data = document.data() else { return nil }
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        return try JSONDecoder().decode(UserProfile.self, from: jsonData)
    }
    
    func updateUserProfile(_ profile: UserProfile) async throws {
        try await saveUserProfile(profile)
    }
    
    // MARK: - User Profile Updates
    
    func updateUsername(_ newUsername: String) async throws {
        guard let currentUser = currentUser else {
            throw FirebaseError.userNotAuthenticated
        }
        
        print("🔄 FirebaseService: Updating username to: \(newUsername)")
        
        // Update Firebase Auth display name
        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.displayName = newUsername
        try await changeRequest.commitChanges()
        
        // Update user profile in Firestore
        let userRef = db.collection("users").document(currentUser.uid)
        try await userRef.updateData([
            "username": newUsername
        ])
        
        // Update all posts by this user
        let postsQuery = db.collection("posts").whereField("userId", isEqualTo: currentUser.uid)
        let postsSnapshot = try await postsQuery.getDocuments()
        
        print("🔄 FirebaseService: Updating \(postsSnapshot.documents.count) posts with new username")
        
        for document in postsSnapshot.documents {
            try await document.reference.updateData([
                "username": newUsername
            ])
        }
        
        print("✅ FirebaseService: Username updated successfully for user and all posts")
        
        // Post notification to trigger UI updates
        await MainActor.run {
            NotificationCenter.default.post(name: .userProfileUpdated, object: nil)
        }
    }
    
    // MARK: - Video Upload
    
    func uploadVideo(videoURL: URL, caption: String, tags: [FartTag]) async throws -> String {
        guard let currentUser = currentUser else {
            throw FirebaseError.userNotAuthenticated
        }
        
        let videoId = UUID().uuidString
        let videoRef = storage.reference().child("videos/\(currentUser.uid)/\(videoId).mp4")
        
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"
        
        _ = try await videoRef.putFileAsync(from: videoURL, metadata: metadata)
        let downloadURL = try await videoRef.downloadURL()
        
        let post = FartPost(
            userId: currentUser.uid,
            username: currentUser.displayName ?? "User",
            userAvatar: currentUser.photoURL?.absoluteString ?? "",
            audioURL: downloadURL.absoluteString,
            caption: caption,
            tags: tags,
            intensity: Int.random(in: 1...5),
            classification: FartClassification.allCases.randomElement() ?? .normal,
            whiffCount: 0,
            commentCount: 0,
            shareCount: 0,
            isLiked: false,
            timestamp: Date()
        )
        
        try await savePost(post)
        try await updateUserPostCount(userId: currentUser.uid, increment: 1)
        
        return post.id
    }
    
    // MARK: - Posts
    
    func savePost(_ post: FartPost) async throws {
        let data = try JSONEncoder().encode(post)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        
        try await db.collection("posts").document(post.id).setData(dict)
    }
    
    func getPosts(limit: Int = 20) async throws -> [FartPost] {
        print("🔄 FirebaseService: getPosts called with limit: \(limit)")
        
        let snapshot = try await db.collection("posts")
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        print("🔄 FirebaseService: Got \(snapshot.documents.count) documents from Firestore")
        
        var posts: [FartPost] = []
        
        for document in snapshot.documents {
            do {
                let data = document.data()
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let post = try JSONDecoder().decode(FartPost.self, from: jsonData)
                posts.append(post)
                print("✅ FirebaseService: Decoded post with ID: \(post.id)")
            } catch {
                print("❌ FirebaseService: Failed to decode post \(document.documentID): \(error.localizedDescription)")
            }
        }
        
        print("✅ FirebaseService: Returning \(posts.count) posts")
        return posts
    }
    
    func getUserPosts(userId: String, limit: Int = 20) async throws -> [FartPost] {
        let snapshot = try await db.collection("posts")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return try snapshot.documents.compactMap { document in
            let data = document.data()
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            return try JSONDecoder().decode(FartPost.self, from: jsonData)
        }
    }
    
    func likePost(postId: String) async throws {
        guard let currentUser = currentUser else {
            throw FirebaseError.userNotAuthenticated
        }
        
        let postRef = db.collection("posts").document(postId)
        let userRef = db.collection("users").document(currentUser.uid)
        
        try await db.runTransaction({ transaction, errorPointer in
            do {
                let postDoc = try transaction.getDocument(postRef)
                let userDoc = try transaction.getDocument(userRef)
                
                guard let postData = postDoc.data(),
                      let userData = userDoc.data() else {
                    let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document not found"])
                    errorPointer?.pointee = error
                    return nil
                }
                
                var currentWhiffCount = postData["whiffCount"] as? Int ?? 0
                var currentPostCount = userData["postCount"] as? Int ?? 0
                
                currentWhiffCount += 1
                currentPostCount += 1
                
                transaction.updateData(["whiffCount": currentWhiffCount], forDocument: postRef)
                transaction.updateData(["postCount": currentPostCount], forDocument: userRef)
                
                return nil
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }
        })
    }
    
    func unlikePost(postId: String) async throws {
        guard let currentUser = currentUser else {
            throw FirebaseError.userNotAuthenticated
        }
        
        let postRef = db.collection("posts").document(postId)
        let userRef = db.collection("users").document(currentUser.uid)
        
        try await db.runTransaction({ transaction, errorPointer in
            do {
                let postDoc = try transaction.getDocument(postRef)
                let userDoc = try transaction.getDocument(userRef)
                
                guard let postData = postDoc.data(),
                      let userData = userDoc.data() else {
                    let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document not found"])
                    errorPointer?.pointee = error
                    return nil
                }
                
                var currentWhiffCount = postData["whiffCount"] as? Int ?? 0
                var currentPostCount = userData["postCount"] as? Int ?? 0
                
                currentWhiffCount = max(0, currentWhiffCount - 1)
                currentPostCount = max(0, currentPostCount - 1)
                
                transaction.updateData(["whiffCount": currentWhiffCount], forDocument: postRef)
                transaction.updateData(["postCount": currentPostCount], forDocument: userRef)
                
                return nil
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }
        })
    }
    
    // MARK: - Sample Data Generation
    
    func createSamplePosts() async throws {
        print("🔄 FirebaseService: Creating sample posts from multiple users...")
        
        let sampleUsers = [
            ("user1", "gassy_greg", "https://example.com/avatar1.jpg"),
            ("user2", "fart_master", "https://example.com/avatar2.jpg"),
            ("user3", "wind_wizard", "https://example.com/avatar3.jpg"),
            ("user4", "toot_titan", "https://example.com/avatar4.jpg")
        ]
        
        let sampleVideos = [
            "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4",
            "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4",
            "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4",
            "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4"
        ]
        
        let sampleCaptions = [
            "Just dropped a classic! 💨",
            "This one was legendary! 🔥",
            "Silent but deadly 😈",
            "The neighbors heard this one 😂",
            "Pure musical genius 🎵",
            "Explosive performance! 💥",
            "Squeaky surprise! 🐭",
            "Wet and wild! 💦"
        ]
        
        for (index, user) in sampleUsers.enumerated() {
            let post = FartPost(
                userId: user.0,
                username: user.1,
                userAvatar: user.2,
                audioURL: sampleVideos[index % sampleVideos.count],
                caption: sampleCaptions[index % sampleCaptions.count],
                tags: [FartTag.allCases.randomElement() ?? .squeaky],
                intensity: Int.random(in: 1...5),
                classification: FartClassification.allCases.randomElement() ?? .classic,
                whiffCount: Int.random(in: 0...100),
                commentCount: Int.random(in: 0...20),
                shareCount: Int.random(in: 0...10),
                isLiked: false,
                timestamp: Date().addingTimeInterval(TimeInterval(-index * 3600)) // Different timestamps
            )
            
            try await savePost(post)
            print("✅ FirebaseService: Created sample post for user: \(user.1)")
        }
        
        print("✅ FirebaseService: Sample posts created successfully")
    }
    
    // MARK: - Helper Methods
    
    private func updateUserPostCount(userId: String, increment: Int) async throws {
        let userRef = db.collection("users").document(userId)
        
        try await db.runTransaction({ transaction, errorPointer in
            do {
                let userDoc = try transaction.getDocument(userRef)
                
                guard let userData = userDoc.data() else {
                    let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document not found"])
                    errorPointer?.pointee = error
                    return nil
                }
                
                let currentPostCount = userData["postCount"] as? Int ?? 0
                let newPostCount = max(0, currentPostCount + increment)
                
                transaction.updateData(["postCount": newPostCount], forDocument: userRef)
                
                return nil
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }
        })
    }
    
    // MARK: - Storage Cleanup
    
    func cleanupOldStorage() async throws {
        print("🔄 FirebaseService: Starting storage cleanup...")
        
        // Delete the old fart_videos folder
        let oldFolderRef = storage.reference().child("fart_videos")
        
        do {
            // List all files in the old folder
            let result = try await oldFolderRef.listAll()
            
            // Delete each file
            for item in result.items {
                try await item.delete()
                print("✅ FirebaseService: Deleted old file: \(item.name)")
            }
            
            // Delete subdirectories if any
            for prefix in result.prefixes {
                let subResult = try await prefix.listAll()
                for item in subResult.items {
                    try await item.delete()
                    print("✅ FirebaseService: Deleted old file: \(item.name)")
                }
            }
            
            print("✅ FirebaseService: Storage cleanup completed successfully")
        } catch {
            print("❌ FirebaseService: Storage cleanup failed: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - Error Types

enum FirebaseError: Error, LocalizedError {
    case authenticationRequired
    case userNotAuthenticated
    case userNotFound
    case documentNotFound
    case invalidData
    case uploadFailed(String)
    case custom(String)
    case presentationError
    case googleSignInError

    var errorDescription: String? {
        switch self {
        case .authenticationRequired: return "Authentication is required for this operation."
        case .userNotAuthenticated: return "User is not authenticated."
        case .userNotFound: return "User not found."
        case .documentNotFound: return "Document not found in Firestore."
        case .invalidData: return "Invalid data format."
        case .uploadFailed(let message): return "Upload failed: \(message)"
        case .custom(let message): return message
        case .presentationError: return "Could not present Google Sign-In UI."
        case .googleSignInError: return "Google Sign-In failed."
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let userProfileUpdated = Notification.Name("userProfileUpdated")
}
