# Firebase Setup Guide for FartApp

## 🚀 Quick Start

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Name it "FartApp"
4. Enable Google Analytics (optional)
5. Click "Create project"

### 2. Add iOS App to Firebase
1. In Firebase Console, click the iOS icon (+ Add app)
2. Enter Bundle ID: `AK.FartApp`
3. Enter App nickname: "FartApp"
4. Click "Register app"
5. Download the `GoogleService-Info.plist` file

### 3. Replace Configuration File
1. Replace the placeholder `GoogleService-Info.plist` in your project with the downloaded file
2. Make sure it's added to your Xcode project target

### 4. Add Firebase Packages via SPM
1. In Xcode, go to File → Add Package Dependencies
2. Add these Firebase packages:

```
https://github.com/firebase/firebase-ios-sdk
```

3. Select these packages:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseStorage
   - FirebaseFirestoreSwift

### 5. Enable Firebase Services

#### Authentication
1. In Firebase Console, go to Authentication → Sign-in method
2. Enable "Email/Password"
3. Click "Save"

#### Firestore Database
1. Go to Firestore Database → Create database
2. Start in test mode (for development)
3. Choose a location close to your users

#### Storage
1. Go to Storage → Get started
2. Start in test mode (for development)
3. Choose the same location as Firestore

### 6. Security Rules

#### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read all posts
    match /posts/{postId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Users can only access their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /videos/{videoId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 🔧 Features Implemented

### ✅ Authentication
- Email/password sign up and sign in
- User profile creation
- Authentication state management

### ✅ Video Upload
- Video upload to Firebase Storage
- Automatic post creation in Firestore
- Progress tracking and error handling

### ✅ Social Feed
- Real-time post loading from Firestore
- Like/unlike functionality
- User post counts

### ✅ User Profiles
- User profile management
- Post count tracking
- Follower/following system (ready for implementation)

## 🎯 Next Steps

1. **Complete Firebase Setup** - Follow the steps above
2. **Test Authentication** - Try signing up and signing in
3. **Test Video Upload** - Record and upload a video
4. **Test Feed** - View uploaded videos in the feed
5. **Add Post Creation UI** - Create a form for captions and tags
6. **Add Comments** - Implement comment functionality
7. **Add Push Notifications** - Notify users of new posts/likes

## 💰 Firebase Pricing

### Free Tier (Spark Plan)
- **Authentication**: 10,000 users/month
- **Firestore**: 1GB storage, 50,000 reads/day, 20,000 writes/day
- **Storage**: 5GB storage, 1GB/day download
- **Perfect for MVP and initial launch!**

### Paid Tier (Blaze Plan)
- Pay-as-you-go pricing
- Scales automatically with usage
- No upfront costs

## 🐛 Troubleshooting

### Common Issues
1. **"Firebase not configured"** - Make sure `GoogleService-Info.plist` is in your project
2. **"Permission denied"** - Check Firestore and Storage security rules
3. **"Network error"** - Verify internet connection and Firebase project settings

### Debug Tips
- Check Xcode console for Firebase error messages
- Verify Firebase project settings match your app
- Test with Firebase Console to ensure services are working

## 📱 App Features

Your FartApp now has:
- ✅ User authentication
- ✅ Video recording and upload
- ✅ Social feed with real posts
- ✅ Like/unlike functionality
- ✅ User profiles
- ✅ Real-time data sync

Ready to launch your gassy social network! 🚀💨
