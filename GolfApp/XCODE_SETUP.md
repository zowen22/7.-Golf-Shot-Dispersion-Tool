# Xcode Setup Guide
## Steps to first successful build (~45 min)

---

## 1. Create the Xcode Project

1. Open Xcode → File → New → Project
2. Choose: iOS → App
3. Options:
   - Product Name: `GolfApp`
   - Bundle ID: `com.yourname.golfapp`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - ✅ Use Core Data: **NO**
   - ✅ Include Tests: **YES**
4. Save to: `7.-Golf-Shot-Dispersion-Tool/GolfApp/` (this folder)
5. Xcode auto-generates `ContentView.swift` and `GolfAppApp.swift` — **delete both**,
   they're already written in the repo
6. Add all `.swift` files from this folder tree to the project target

---

## 2. Add SPM Dependencies

File → Add Package Dependencies → paste each URL:

| Package | URL | Version | Products |
|---------|-----|---------|----------|
| Firebase iOS SDK | `https://github.com/firebase/firebase-ios-sdk` | Up To Next Major 10.0.0 | FirebaseAuth, FirebaseFirestore, FirebaseFirestoreSwift |
| Mapbox Maps | `https://github.com/mapbox/mapbox-maps-ios` | Up To Next Major 11.0.0 | MapboxMaps |
| Google Sign-In | `https://github.com/google/GoogleSignIn-iOS` | Up To Next Major 7.0.0 | GoogleSignIn, GoogleSignInSwift |
| RevenueCat | `https://github.com/RevenueCat/purchases-ios` | Up To Next Major 4.0.0 | RevenueCat |

---

## 3. Firebase Setup

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Create **two** projects: `GolfApp-Dev` and `GolfApp-Prod`
3. For each project:
   - Add an iOS app with your bundle ID
   - Download `GoogleService-Info.plist`
4. In Xcode:
   - Add both plist files to the project (do **not** add to git — already in .gitignore)
   - Create two build schemes: `GolfApp Dev` and `GolfApp Prod`
   - In each scheme's Build → Pre-actions, copy the correct plist:
     ```
     cp "${PROJECT_DIR}/GolfApp/Config/GoogleService-Info-Dev.plist" \
        "${BUILT_PRODUCTS_DIR}/GoogleService-Info.plist"
     ```
5. In `GolfAppApp.swift`: uncomment `import Firebase` and `FirebaseApp.configure()`
6. In `AuthService.swift` and `FirestoreService.swift`: uncomment the Firebase import and replace all `throw AuthError.notImplemented` stubs with real Firebase SDK calls (each method has inline comments)

---

## 4. API Keys (Info.plist)

Add these keys to Info.plist (never commit values — use xcconfig):

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>GolfApp uses your location to find nearby courses and calculate distances to the pin.</string>

<key>MBXAccessToken</key>
<string>$(MAPBOX_TOKEN)</string>

<key>GOLFBERT_API_KEY</key>
<string>$(GOLFBERT_API_KEY)</string>
```

Create `Config/Secrets.xcconfig` (git-ignored):
```
MAPBOX_TOKEN = pk.eyJ1IjoiWU9VUl...
GOLFBERT_API_KEY = your-golfbert-key-here
```

In Xcode project settings → Info → Configurations, set the xcconfig for each scheme.

### API Key sources:
- **Mapbox**: [account.mapbox.com](https://account.mapbox.com) — create a public token
- **Golfbert**: [golfbert.com/api](https://golfbert.com/api) — register for API access

---

## 5. Signing & Capabilities

Target → Signing & Capabilities → + Capability:
- ✅ **Sign In with Apple** (required by App Store for apps with social login)
- ✅ **In-App Purchase** (required for StoreKit 2 subscription)
- ✅ **Location** (already handled by entitlement from NSLocationWhenInUseUsageDescription)

---

## 6. Wire Mapbox (after SPM resolves)

In `Views/Map/MapboxMapView.swift`:
1. Uncomment `import MapboxMaps` at the top
2. Replace `makeUIView` placeholder UIView with real `MapView(frame:mapInitOptions:)`
3. Implement `updateUIView` to update the dispersion FillLayer source
4. Implement `Coordinator` gesture handlers for shot marker drag

---

## 7. Wire StoreKit 2 (Paywall)

In `ViewModels/OnboardingViewModel.swift`:
1. Replace `purchase(productID:)` stub with StoreKit 2 purchase flow:
   ```swift
   let products = try await Product.products(for: [productID])
   guard let product = products.first else { return }
   let result = try await product.purchase()
   switch result {
   case .success: advance()
   default: break
   }
   ```
2. Add product IDs to App Store Connect before testing

---

## 8. First Build Checklist

- [ ] .xcodeproj created, all Swift files added to target
- [ ] SPM packages resolved (Firebase, Mapbox, GoogleSignIn, RevenueCat)
- [ ] `import Firebase` + `FirebaseApp.configure()` uncommented in GolfAppApp.swift
- [ ] `GoogleService-Info.plist` added for dev environment
- [ ] Info.plist has NSLocationWhenInUseUsageDescription, MBXAccessToken, GOLFBERT_API_KEY
- [ ] Sign In with Apple + In-App Purchase capabilities enabled
- [ ] `import MapboxMaps` uncommented in MapboxMapView.swift

**Expected first build state:** Compiles and launches. Auth screen shows. Map screen shows placeholder until Mapbox import is uncommented. All Firebase calls return stub errors until SDK is wired.

---

## Golfbert API Field Name Note

Our models use `convertFromSnakeCase` decoding (set in NetworkService). If Golfbert returns field names that don't follow snake_case → camelCase conversion cleanly, add explicit `CodingKeys` to Course or Hole. Verify against a real API response on first call and adjust models if needed.
