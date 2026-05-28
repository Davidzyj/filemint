# Project Progress

## 2026-05-28

### Stage 1: Foundation

- Status: Complete
- Created product direction and MVP plan.
- Selected product name: FileMint / 文件薄荷.
- Selected bundle ID: `com.zhouyajie.filemint`.
- Confirmed workspace started empty.
- Created the native SwiftUI Xcode project skeleton.

### Stage 2: Core File Processing

- Status: Complete
- Implemented local PDF compression.
- Implemented images-to-PDF creation.
- Implemented PDF-to-JPG ZIP export.
- Implemented JPG/PNG/HEIC image conversion.
- Added local processed-file history and sandbox output storage.

### Stage 3: App Experience

- Status: Complete
- Built the home screen, tool screens, settings screen, recent files list, and iOS share sheet export.
- Added English and Simplified Chinese UI text through the app locale layer.
- Added China-region Chinese fallback and English fallback for other regions.
- Added localized `CFBundleDisplayName` in `InfoPlist.strings`.

### Stage 4: Web and Store Assets

- Status: Complete
- Generated first app icon source artwork.
- Added 1024x1024 App Store icon PNG with no alpha channel.
- Added bilingual Privacy Policy and Support pages under `site/`.
- Added GitHub Pages workflow for publishing `site/`.
- Added App Store Connect draft metadata.
- Generated English and Simplified Chinese 6.5-inch App Store screenshots at `1242x2688`.

### Stage 5: Verification and Handoff

- Status: Complete, except remote GitHub repository creation is blocked by token permissions.
- Added handoff documentation.
- Verified simulator build with:
  `xcodebuild -project FileMint.xcodeproj -scheme FileMint -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max,OS=18.6' CODE_SIGNING_ALLOWED=NO build`
- Verified screenshot generation with `scripts/capture_screenshots.sh`.
- Initialized git repository and created initial commit `fe1f7de`.
- Attempted to create GitHub repository `filemint`; GitHub API returned `403 Resource not accessible by personal access token`.
