# 🔐 Google Sign-In Setup Guide for FartApp

This guide will help you add Google Sign-In authentication to your FartApp project.

## 📋 Prerequisites

- Xcode project with Firebase already configured
- GoogleService-Info.plist file in your project
- Firebase Authentication enabled in Firebase Console

## 🚀 Step 1: Add Google Sign-In Package

1. **Open your FartApp.xcodeproj in Xcode**
2. **Go to File → Add Package Dependencies**
3. **Enter this URL**: `https://github.com/google/GoogleSignIn-iOS`
4. **Select the package** and click "Add Package"
5. **Make sure it's added to your FartApp target**

## 🔧 Step 2: Configure URL Schemes

1. **In Xcode, select your project** (FartApp)
2. **Select your target** (FartApp)
3. **Go to Info tab**
4. **Expand "URL Types"**
5. **Add a new URL Type**:
   - **Identifier**: `REVERSED_CLIENT_ID` (from GoogleService-Info.plist)
   - **URL Schemes**: Copy the value from `REVERSED_CLIENT_ID` in GoogleService-Info.plist
   - **Role**: Editor

## 📱 Step 3: Update Info.plist

Add these entries to your Info.plist file:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID_HERE</string>
        </array>
    </dict>
</array>
```

## 🔑 Step 4: Firebase Console Configuration

1. **Go to Firebase Console** → Your Project → Authentication
2. **Click "Sign-in method" tab**
3. **Enable "Google" provider**
4. **Add your support email**
5. **Save the changes**

## 📱 Step 5: iOS Configuration

1. **In Firebase Console**, go to Project Settings
2. **Add iOS app** if not already added
3. **Download the updated GoogleService-Info.plist**
4. **Replace the old file** in your Xcode project

## 🧪 Step 6: Test the Implementation

1. **Build and run** your project
2. **Try signing in with Google**
3. **Check the console** for any error messages

## 🐛 Troubleshooting

### Common Issues:

1. **"Could not present Google Sign-In UI"**
   - Check that URL schemes are properly configured
   - Verify REVERSED_CLIENT_ID is correct

2. **"Google Sign-In failed"**
   - Check Firebase Console configuration
   - Verify GoogleService-Info.plist is up to date

3. **Build errors with GoogleSignIn**
   - Make sure the package is added to your target
   - Clean build folder and rebuild

## 📚 Additional Resources

- [Google Sign-In iOS Documentation](https://developers.google.com/identity/sign-in/ios)
- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Google Sign-In iOS GitHub](https://github.com/google/GoogleSignIn-iOS)

## ✅ What's Already Implemented

The following code has been added to your project:

1. **FirebaseService.swift**: Added `signInWithGoogle()` method
2. **LoginView.swift**: Added Google Sign-In button and UI
3. **Error handling**: Added Google Sign-In specific error cases

## 🎯 Next Steps

After completing the setup:

1. **Test Google Sign-In** with a test account
2. **Customize the UI** if needed
3. **Add additional providers** (Apple, Facebook, etc.)
4. **Implement user profile management**

---

**Note**: Make sure to test on a physical device, as Google Sign-In may not work properly in the iOS Simulator.
