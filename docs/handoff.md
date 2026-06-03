# FileMint Handoff

Last updated: 2026-05-28

## Current Product

FileMint / 文件薄荷 is an iPhone-only SwiftUI app for local file processing.

- Bundle ID: `com.zhouyajie.filemint`
- Version: `1.0.0`
- Deployment target: iOS 17.0
- Supports: iPhone only
- Account/backend: none
- Data: local device storage only
- Languages: English and Simplified Chinese
- China region behavior: app text chooses Simplified Chinese when device region is CN; otherwise English

## Implemented MVP

- Compress PDF
- Images to PDF
- PDF pages to JPG ZIP
- Image conversion between JPG, PNG, and HEIC
- Recent processed files stored in the app container
- iOS share sheet for exported files
- Settings page with Privacy Policy, Support, and email links
- Localized display name through `InfoPlist.strings`
- App icon generated and added to asset catalog
- GitHub Pages-ready privacy/support pages in `site/`
- App Store Connect draft metadata in `docs/app-store-connect-template.md`

## Important Paths

- Xcode project: `FileMint.xcodeproj`
- App entry: `FileMint/FileMintApp.swift`
- Models: `FileMint/Models/`
- Processing services: `FileMint/Services/`
- SwiftUI views: `FileMint/Views/`
- App icon: `FileMint/Assets.xcassets/AppIcon.appiconset/`
- Web pages: `site/`
- App Store metadata: `docs/app-store-connect-template.md`
- Screenshot script: `scripts/capture_screenshots.sh`
- Generated screenshots: `build/screenshots/`

## Build Commands

List project:

```sh
xcodebuild -list -project FileMint.xcodeproj
```

Build simulator:

```sh
xcodebuild -project FileMint.xcodeproj -scheme FileMint -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max,OS=18.6' CODE_SIGNING_ALLOWED=NO build
```

Capture App Store screenshots:

```sh
scripts/capture_screenshots.sh
```

## Screenshot Mode

The app supports deterministic screenshot mode through launch arguments:

- `-FileMintScreenshot`
- `-FileMintLanguage en`
- `-FileMintLanguage zh-Hans`
- `-FileMintScreen home`
- `-FileMintScreen compress`
- `-FileMintScreen images-to-pdf`
- `-FileMintScreen settings`

Screenshot mode seeds visible sample data and avoids file picker prompts.

## GitHub Pages

The intended repository is `filemint` under GitHub user `Davidzyj`.

Expected public URLs:

- `https://davidzyj.github.io/filemint/`
- `https://davidzyj.github.io/filemint/en/privacy.html`
- `https://davidzyj.github.io/filemint/en/support.html`
- `https://davidzyj.github.io/filemint/zh-Hans/privacy.html`
- `https://davidzyj.github.io/filemint/zh-Hans/support.html`

Pages are published from `site/` through `.github/workflows/pages.yml`.

Repository and Pages status:

- Repository: `https://github.com/Davidzyj/filemint`
- Remote: `origin https://github.com/Davidzyj/filemint.git`
- Branch: `main`
- Pages mode: GitHub Actions workflow
- Pages deploy workflow: completed successfully on 2026-06-03
- Public site: `https://davidzyj.github.io/filemint/`

## Remaining Owner Actions

- Confirm Apple Developer team and signing identity.
- Register Bundle ID in Apple Developer if needed.
- Create App Store Connect app record.
- Fill legal/copyright/contact phone details.
- Archive and upload the signed build.
- Complete App Privacy and export compliance questions.
- Submit for App Review.
