import Foundation

enum AppLanguage {
    case english
    case simplifiedChinese

    var pathComponent: String {
        switch self {
        case .english:
            return "en"
        case .simplifiedChinese:
            return "zh-Hans"
        }
    }
}

@MainActor
final class AppLocale: ObservableObject {
    let language: AppLanguage

    init(locale: Locale = .current) {
        if let forced = ScreenshotConfig.forcedLanguageCode {
            language = forced.hasPrefix("zh") ? .simplifiedChinese : .english
        } else if let preferredIdentifier = Locale.preferredLanguages.first {
            language = Self.language(forPreferredIdentifier: preferredIdentifier)
        } else if locale.region?.identifier.uppercased() == "CN" {
            language = .simplifiedChinese
        } else {
            language = .english
        }
    }

    func text(_ key: String) -> String {
        switch language {
        case .english:
            return Self.english[key] ?? key
        case .simplifiedChinese:
            return Self.simplifiedChinese[key] ?? Self.english[key] ?? key
        }
    }

    func privacyURL() -> URL {
        URL(string: "\(AppConstants.webBaseURL)/\(language.pathComponent)/privacy.html")!
    }

    func supportURL() -> URL {
        URL(string: "\(AppConstants.webBaseURL)/\(language.pathComponent)/support.html")!
    }

    func formattedBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = language == .simplifiedChinese ? Locale(identifier: "zh_Hans_CN") : Locale(identifier: "en_US")
        return formatter.string(from: date)
    }

    func pdfCompressionDetail(percent: Int) -> String {
        switch language {
        case .english:
            return "PDF compressed by \(percent)%"
        case .simplifiedChinese:
            return "PDF 已压缩 \(percent)%"
        }
    }

    func imageCountDetail(_ count: Int) -> String {
        switch language {
        case .english:
            return "\(count) image\(count == 1 ? "" : "s")"
        case .simplifiedChinese:
            return "\(count) 张图片"
        }
    }

    func pageCountDetail(_ count: Int) -> String {
        switch language {
        case .english:
            return "\(count) page\(count == 1 ? "" : "s")"
        case .simplifiedChinese:
            return "\(count) 页"
        }
    }
}

private extension AppLocale {
    static func language(forPreferredIdentifier identifier: String) -> AppLanguage {
        let locale = Locale(identifier: identifier)

        guard locale.language.languageCode?.identifier == "zh" else {
            return .english
        }

        if locale.language.script?.identifier == "Hans" {
            return .simplifiedChinese
        }

        if locale.region?.identifier.uppercased() == "CN" {
            return .simplifiedChinese
        }

        return .english
    }

    static let english: [String: String] = [
        "app.title": "FileMint",
        "app.subtitle": "Local file compression and conversion",
        "nav.settings": "Settings",
        "section.tools": "Tools",
        "section.recent": "Recent",
        "recent.empty": "No processed files yet",
        "recent.demo.detail": "PDF compressed by 48%",
        "button.choosePDF": "Choose PDF",
        "button.chooseImages": "Choose Images",
        "button.chooseImage": "Choose Image",
        "button.compress": "Compress",
        "button.createPDF": "Create PDF",
        "button.exportImages": "Export Images",
        "button.convert": "Convert",
        "button.preview": "Preview",
        "button.share": "Share",
        "button.clear": "Clear",
        "button.privacy": "Privacy Policy",
        "button.support": "Support",
        "button.email": "Email Support",
        "status.ready": "Ready",
        "status.processing": "Processing",
        "status.complete": "Complete",
        "status.output": "Output",
        "status.selected": "Selected",
        "status.files": "Files",
        "status.size": "Size",
        "status.originalSize": "Original",
        "status.previewSize": "Preview",
        "status.previewReady": "Preview ready",
        "status.previewUpdating": "Updating preview",
        "tool.pdfCompress.title": "Compress PDF",
        "tool.pdfCompress.subtitle": "Reduce PDF file size",
        "tool.imagesToPDF.title": "Images to PDF",
        "tool.imagesToPDF.subtitle": "Make one PDF from images",
        "tool.pdfToImages.title": "PDF to Images",
        "tool.pdfToImages.subtitle": "Export pages as JPG ZIP",
        "tool.imageConvert.title": "Image Convert",
        "tool.imageConvert.subtitle": "Convert JPG, PNG, HEIC",
        "compression.title": "Compression",
        "compression.balanced": "Balanced",
        "compression.smaller": "Smaller",
        "compression.bestQuality": "Best Quality",
        "format.title": "Format",
        "settings.about": "About",
        "settings.version": "Version",
        "settings.local": "Local processing",
        "settings.local.value": "No account, no server, no tracking",
        "settings.links": "Links",
        "error.title": "Something went wrong",
        "error.noFile": "Select a file first.",
        "error.noImages": "Select at least one image.",
        "result.saved": "Saved on device",
        "screenshot.sample.pdf": "Quarterly Report.pdf",
        "screenshot.sample.images": "Receipt photos",
        "screenshot.sample.result": "Quarterly Report - small.pdf"
    ]

    static let simplifiedChinese: [String: String] = [
        "app.title": "文件转换器",
        "app.subtitle": "本地文件压缩与格式转换",
        "nav.settings": "设置",
        "section.tools": "工具",
        "section.recent": "最近",
        "recent.empty": "还没有处理过的文件",
        "recent.demo.detail": "PDF 已压缩 48%",
        "button.choosePDF": "选择 PDF",
        "button.chooseImages": "选择图片",
        "button.chooseImage": "选择图片",
        "button.compress": "压缩",
        "button.createPDF": "生成 PDF",
        "button.exportImages": "导出图片",
        "button.convert": "转换",
        "button.preview": "预览",
        "button.share": "分享",
        "button.clear": "清除",
        "button.privacy": "隐私政策",
        "button.support": "支持",
        "button.email": "邮件支持",
        "status.ready": "就绪",
        "status.processing": "处理中",
        "status.complete": "已完成",
        "status.output": "输出",
        "status.selected": "已选择",
        "status.files": "文件",
        "status.size": "大小",
        "status.originalSize": "原始大小",
        "status.previewSize": "预览大小",
        "status.previewReady": "预览已生成",
        "status.previewUpdating": "正在更新预览",
        "tool.pdfCompress.title": "压缩 PDF",
        "tool.pdfCompress.subtitle": "减小 PDF 文件体积",
        "tool.imagesToPDF.title": "图片转 PDF",
        "tool.imagesToPDF.subtitle": "多张图片合成 PDF",
        "tool.pdfToImages.title": "PDF 转图片",
        "tool.pdfToImages.subtitle": "页面导出为 JPG ZIP",
        "tool.imageConvert.title": "图片格式转换",
        "tool.imageConvert.subtitle": "转换 JPG、PNG、HEIC",
        "compression.title": "压缩",
        "compression.balanced": "均衡",
        "compression.smaller": "更小",
        "compression.bestQuality": "高质量",
        "format.title": "格式",
        "settings.about": "关于",
        "settings.version": "版本",
        "settings.local": "本地处理",
        "settings.local.value": "无需账号、无服务器、无追踪",
        "settings.links": "链接",
        "error.title": "出现问题",
        "error.noFile": "请先选择文件。",
        "error.noImages": "请至少选择一张图片。",
        "result.saved": "已保存在设备上",
        "screenshot.sample.pdf": "季度报告.pdf",
        "screenshot.sample.images": "票据照片",
        "screenshot.sample.result": "季度报告-小体积.pdf"
    ]
}
