# Development Plan

## Stage 1: Foundation

- Create a git-managed SwiftUI iPhone-only Xcode project.
- Configure app version `1.0.0`, bundle ID `com.zhouyajie.filemint`, and iPhone target family.
- Add bilingual display names and app resources.

## Stage 2: Core File Processing

- Implement local PDF compression using PDFKit and UIKit rendering.
- Implement image-to-PDF conversion.
- Implement PDF-to-JPG ZIP export.
- Implement image conversion to JPEG, PNG, and HEIC.
- Store processed files and history locally.

## Stage 3: App Experience

- Build SwiftUI screens for dashboard, tool details, results, recent files, and settings.
- Add Chinese/English runtime localization.
- Add user-initiated links to privacy and support pages.

## Stage 4: Web and Store Assets

- Add GitHub Pages-ready privacy policy and support pages in English and Chinese.
- Prepare App Store Connect metadata in English and Chinese.
- Generate a 1024x1024 app icon without alpha.
- Generate 6.5-inch screenshots in English and Chinese.

## Stage 5: Verification and Handoff

- Build the app with Xcode.
- Verify icon metadata and screenshot dimensions.
- Initialize git repository and commit.
- Create or prepare GitHub repository and enable Pages.
- Write handoff notes for the next agent or maintainer.

