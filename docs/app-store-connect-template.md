# FileMint App Store Connect Template

Last updated: 2026-05-28

## App Record

- App name: FileMint
- Simplified Chinese listing name: 文件薄荷
- Bundle ID: `com.zhouyajie.filemint`
- SKU: `filemint-ios-001`
- Version: `1.0.0`
- Platform: iOS
- Device support: iPhone only
- Primary language: English
- Secondary language: Simplified Chinese
- Category suggestion: Productivity
- Pricing suggestion: Free
- Support email: `jay212315@gmail.com`
- Privacy Policy URL: `https://davidzyj.github.io/filemint/en/privacy.html`
- Support URL: `https://davidzyj.github.io/filemint/en/support.html`

## English Listing

Name:
FileMint

Subtitle:
Local PDF and image tools

Promotional Text:
Compress PDFs, create PDFs from images, export PDF pages, and convert image formats directly on your iPhone.

Description:
FileMint is a lightweight file utility for iPhone that keeps document work local. Compress PDFs, turn images into a PDF, export PDF pages as images, and convert JPG, PNG, and HEIC files without creating an account.

Files you choose are processed on your device and saved locally. FileMint does not require a backend, account, analytics service, or tracking SDK.

Key features:
- Compress PDF files
- Create one PDF from multiple images
- Export PDF pages as JPG files in a ZIP archive
- Convert images between JPG, PNG, and HEIC
- Keep recent processed files on device
- Share output files with the standard iOS share sheet

Keywords:
pdf,compress,converter,image,heic,jpg,png,zip,document,file

Support URL:
`https://davidzyj.github.io/filemint/en/support.html`

Privacy Policy URL:
`https://davidzyj.github.io/filemint/en/privacy.html`

Marketing URL:
Leave blank for MVP, or use `https://davidzyj.github.io/filemint/`

## Simplified Chinese Listing

Name:
文件薄荷

Subtitle:
本地 PDF 与图片工具

Promotional Text:
在 iPhone 本地压缩 PDF、图片生成 PDF、导出 PDF 页面，并转换常见图片格式。

Description:
文件薄荷是一款轻量的 iPhone 文件处理工具，适合快速完成日常文档整理。你可以压缩 PDF、将多张图片合成为 PDF、把 PDF 页面导出为图片 ZIP，也可以在 JPG、PNG、HEIC 格式之间转换图片。

你选择的文件会在设备本地处理并保存。文件薄荷不需要账号、不连接后端、不使用统计服务或追踪 SDK。

主要功能：
- 压缩 PDF 文件
- 多张图片生成一个 PDF
- 将 PDF 页面导出为 JPG，并打包为 ZIP
- 在 JPG、PNG、HEIC 之间转换图片
- 在设备上保留最近处理记录
- 使用 iOS 系统分享面板导出结果文件

Keywords:
PDF,压缩,转换,图片,HEIC,JPG,PNG,ZIP,文档,文件

Support URL:
`https://davidzyj.github.io/filemint/zh-Hans/support.html`

Privacy Policy URL:
`https://davidzyj.github.io/filemint/zh-Hans/privacy.html`

Marketing URL:
Leave blank for MVP, or use `https://davidzyj.github.io/filemint/`

## App Privacy

Suggested App Privacy answers based on the current implementation:

- Data collection: No data collected
- Tracking: No
- Third-party advertising: No
- Analytics: No
- Account creation: No
- User content uploaded to developer servers: No
- Files processed locally: Yes

Rationale:
The app processes files locally in the iOS app container, stores recent output history on device, and does not include backend calls, analytics SDKs, ads, or tracking code. Network activity is only user-initiated through external Privacy Policy, Support, or mail links.

## Review Information

Demo account:
Not required. The app has no login or account system.

Review notes:
FileMint is an iPhone-only local file processing app. It does not require network access for file processing and does not collect user data. Reviewers can use the four home-screen tools by selecting local PDF or image files through the iOS file picker, then exporting the output through the iOS share sheet.

Contact:
- Email: `jay212315@gmail.com`
- Phone: owner must fill in App Store Connect
- First name / last name: owner must fill in App Store Connect

## Compliance And Age Rating

Conservative suggested answers:

- Contains unrestricted web access: No
- User-generated content visible to other users: No
- Messaging/social features: No
- Ads: No
- In-app purchases/subscriptions: No
- Gambling/contests: No
- Medical/health data: No
- Financial services/crypto: No
- Location usage: No
- Camera/microphone usage: No
- Export compliance: Uses only Apple system frameworks and standard HTTPS links. No custom encryption beyond Apple platform defaults. Owner should confirm the exact App Store Connect export compliance wording before submission.

Likely age rating:
4+

## Assets

- App icon: `build/app-icons/filemint-icon-1024.png`
- App icon in asset catalog: `FileMint/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`
- English 6.5-inch screenshots: `build/screenshots/en/`
- Simplified Chinese 6.5-inch screenshots: `build/screenshots/zh-Hans/`

## Owner Manual Steps

- Create/confirm Apple Developer team and signing certificate.
- Register Bundle ID `com.zhouyajie.filemint` if it does not exist.
- In Xcode, set the correct Development Team before archiving.
- Create the App Store Connect app record.
- Fill contact phone/legal/copyright owner fields.
- Upload the archive from Xcode Organizer or Transporter.
- Upload final screenshots and the 1024 icon.
- Complete App Privacy questionnaire using the answers above.
- Choose final price, release mode, and availability territories.
- Submit for review.
