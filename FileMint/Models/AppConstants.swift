import Foundation

enum AppConstants {
    static let supportEmail = "jay212315@gmail.com"
    static let webBaseURL = "https://davidzyj.github.io/filemint"
    static let bundleIdentifier = "com.zhouyajie.filemint"

    static var versionString: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }
}

enum ToolRoute: Hashable {
    case pdfCompress
    case imagesToPDF
    case pdfToImages
    case imageConvert
    case settings

    init(tool: ToolKind) {
        switch tool {
        case .pdfCompress:
            self = .pdfCompress
        case .imagesToPDF:
            self = .imagesToPDF
        case .pdfToImages:
            self = .pdfToImages
        case .imageConvert:
            self = .imageConvert
        }
    }
}

enum ScreenshotConfig {
    static let isEnabled = ProcessInfo.processInfo.arguments.contains("-FileMintScreenshot")
        || ProcessInfo.processInfo.environment["FILEMINT_SCREENSHOT_MODE"] == "1"

    static var forcedLanguageCode: String? {
        if let index = ProcessInfo.processInfo.arguments.firstIndex(of: "-FileMintLanguage"),
           ProcessInfo.processInfo.arguments.indices.contains(index + 1) {
            return ProcessInfo.processInfo.arguments[index + 1]
        }
        return ProcessInfo.processInfo.environment["FILEMINT_LANGUAGE"]
    }

    static var initialRoute: ToolRoute? {
        guard let index = ProcessInfo.processInfo.arguments.firstIndex(of: "-FileMintScreen"),
              ProcessInfo.processInfo.arguments.indices.contains(index + 1) else {
            return nil
        }

        switch ProcessInfo.processInfo.arguments[index + 1] {
        case "home":
            return nil
        case "compress":
            return .pdfCompress
        case "images-to-pdf":
            return .imagesToPDF
        case "pdf-to-images":
            return .pdfToImages
        case "image-convert":
            return .imageConvert
        case "settings":
            return .settings
        default:
            return nil
        }
    }
}
