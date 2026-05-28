# FileMint MVP Product Plan

## Product Name

- English: FileMint
- Simplified Chinese: 文件薄荷
- Bundle ID: `com.zhouyajie.filemint`

## Positioning

FileMint is a local-first iPhone file utility for everyday document cleanup: compress oversized PDFs, convert image files, and export PDF pages without accounts, uploads, or background services.

## MVP Scope

1. PDF compression
   - Import a PDF from Files.
   - Choose compression strength: balanced, smaller, or best quality.
   - Render a compressed copy locally and keep it in the app sandbox.

2. File conversion
   - Convert one or more images into a PDF.
   - Export PDF pages as JPG files inside a ZIP archive.
   - Convert one image into JPEG, PNG, or HEIC.

3. Local library
   - Save processed outputs in the app Documents directory.
   - Keep recent result metadata locally.
   - Let users share exported files through the iOS share sheet.

4. Settings and support
   - In-app links to privacy policy and support pages.
   - Support email: `jay212315@gmail.com`.
   - No account system, no analytics, no ads, no tracking.

## Localization

- App UI supports English and Simplified Chinese.
- Runtime UI chooses Simplified Chinese when the device region is China, otherwise English.
- `CFBundleDisplayName` is configured for English and Simplified Chinese. iOS applies bundle display-name localization based on system language.

## Non-Goals for 1.0.0

- Cloud conversion.
- Office document conversion.
- Account login.
- Batch folder processing.
- OCR.
- In-app purchase.

## Future Candidates

- Merge/split PDF.
- Reorder/delete PDF pages.
- Password protect PDF.
- More file formats where iOS provides reliable local APIs.

