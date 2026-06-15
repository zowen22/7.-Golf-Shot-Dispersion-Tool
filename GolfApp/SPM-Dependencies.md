# Swift Package Dependencies

Add these in Xcode → File → Add Package Dependencies

## Firebase iOS SDK
URL: https://github.com/firebase/firebase-ios-sdk
Version: Up To Next Major from 10.0.0
Products to add:
- FirebaseAuth
- FirebaseFirestore
- FirebaseFirestoreSwift

## Mapbox Maps SDK for iOS
URL: https://github.com/mapbox/mapbox-maps-ios
Version: Up To Next Major from 11.0.0
Products to add:
- MapboxMaps

## Google Sign-In SDK
URL: https://github.com/google/GoogleSignIn-iOS
Version: Up To Next Major from 7.0.0
Products to add:
- GoogleSignIn
- GoogleSignInSwift

## RevenueCat (Recommended — simplifies StoreKit 2 entitlement management)
URL: https://github.com/RevenueCat/purchases-ios
Version: Up To Next Major from 4.0.0
Products to add:
- RevenueCat

## After adding all packages:
1. Add `GoogleService-Info.plist` to the project (dev scheme = dev plist, prod scheme = prod plist)
2. Set `MBXAccessToken` in Info.plist for Mapbox
3. Set `GOLFBERT_API_KEY` in xcconfig (never commit the actual key)
4. Enable Push Notifications + Sign In with Apple capabilities in Signing & Capabilities
5. Add `NSLocationWhenInUseUsageDescription` to Info.plist
