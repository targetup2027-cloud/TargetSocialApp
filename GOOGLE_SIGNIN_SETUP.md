# Google Sign-In Setup Guide
**For U-Axis Social App**

---

## 📋 Prerequisites

Before implementing Google Sign-In, you need:
1. Google Cloud Console account
2. Firebase Console account  
3. SHA-1 certificate (`83:68:E0:F4:D5:D5:5F:2D:33:34:1D:09:00:5D:56:4A:01:0B:ED:DC`)

---

## 🔥 Step 1: Create Firebase Project

### 1.1 Create New Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Project name: `U-Axis Social App` (or your preferred name)
4. Enable Google Analytics (optional)
5. Click **"Create project"**

### 1.2 Add Android App
1. Click the **Android** icon
2. **Android package name**: `com.example.social_app`
3. **App nickname**: `U-Axis Social (Android)`
4. **Debug signing certificate SHA-1**: `83:68:E0:F4:D5:D5:5F:2D:33:34:1D:09:00:5D:56:4A:01:0B:ED:DC`
5. Click **"Register app"**
6. **Download** `google-services.json`
7. Click **"Next"** → **"Continue to console"**

### 1.3 Add iOS App
1. Click **"Add app"** → Select **iOS**
2. **iOS bundle ID**: `com.example.socialApp`
3. **App nickname**: `U-Axis Social (iOS)`
4. Click **"Register app"**
5. **Download** `GoogleService-Info.plist`
6. Click **"Next"** → **"Continue to console"**

---

## 📂 Step 2: Add Config Files

### Android
1. Place `google-services.json` in:
   ```
   android/app/google-services.json
   ```

### iOS
1. Open Xcode: `ios/Runner.xcworkspace`
2. Right-click `Runner` folder → **Add Files to "Runner"**
3. Select `GoogleService-Info.plist`
4. Ensure **"Copy items if needed"** is checked
5. Target: **Runner** (checked)

---

## 🔐 Step 3: Enable Google Sign-In

### In Firebase Console
1. Go to **Authentication** → **Sign-in method**
2. Click **Google** → **Enable**
3. **Project support email**: (your email)
4. Click **"Save"**

---

## ⚙️ Step 4: Backend Requirements

The backend (.NET) needs these endpoints:

### Required Endpoint
```http
POST /auth/google
Content-Type: application/json

Request:
{
  "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6..."
}

Response (200):
{
  "user": {
    "id": "uuid",
    "email": "user@gmail.com",
    "displayName": "John Doe",
    "profilePicture": "https://..."
  },
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc..."
}
```

### Backend Implementation Checklist
- [ ] Install Google.Apis.Auth.AspNetCore NuGet package
- [ ] Implement Google ID token validation
- [ ] Extract user info (email, name, picture) from token
- [ ] Create/update user in database if not exists
- [ ] Generate JWT access & refresh tokens
- [ ] Return user data + tokens

**Example C# Code** (if missing):
```csharp
using Google.Apis.Auth;

[HttpPost("google")]
public async Task<IActionResult> GoogleSignIn([FromBody] GoogleSignInRequest request)
{
    var settings = new GoogleJsonWebSignature.ValidationSettings
    {
        Audience = new[] { "YOUR-GOOGLE-CLIENT-ID" }
    };
    
    var payload = await GoogleJsonWebSignature.ValidateAsync(request.IdToken, settings);
    
    var user = await _userService.GetOrCreateUserFromGoogle(
        payload.Email,
        payload.Name,
        payload.Picture
    );
    
    var tokens = _tokenService.GenerateTokens(user);
    
    return Ok(new { user, ...tokens });
}
```

---

## 📱 Step 5: Flutter Implementation

Already added `google_sign_in: ^6.2.2` to `pubspec.yaml`.

Run:
```bash
flutter pub get
```

---

## ✅ Verification Checklist

- [ ] Firebase project created
- [ ] Android app registered with correct package name
- [ ] iOS app registered with correct bundle ID
- [ ] SHA-1 fingerprint added to Firebase
- [ ] `google-services.json` placed in `android/app/`
- [ ] `GoogleService-Info.plist` added to Xcode project
- [ ] Google Sign-In enabled in Firebase Authentication
- [ ] Backend `/auth/google` endpoint implemented
- [ ] Backend validates Google ID tokens
- [ ] Backend returns JWT tokens

---

## 🚨 Common Issues

### "API not enabled" error
- Go to [Google Cloud Console](https://console.cloud.google.com/)
- Enable **"Google Sign-In API"**

### iOS: "No valid credentials"
- Ensure `GoogleService-Info.plist` is in Xcode project
- Check bundle ID matches Firebase configuration

### Android: Sign-in fails
- Verify SHA-1 is registered in Firebase
- Check `google-services.json` is in `android/app/`

---

## 📞 Next Steps

After completing this setup:
1. Implement Google Sign-In UI in Flutter
2. Test on real device (simulator may not work for Google auth)
3. Verify backend receives and validates tokens correctly
