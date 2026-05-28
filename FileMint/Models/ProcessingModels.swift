import CoreGraphics
import Foundation
import UniformTypeIdentifiers

enum ToolKind: String, CaseIterable, Codable, Identifiable {
    case pdfCompress
    case imagesToPDF
    case pdfToImages
    case imageConvert

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .pdfCompress:
            return "doc.zipper"
        case .imagesToPDF:
            return "photo.stack"
        case .pdfToImages:
            return "doc.richtext"
        case .imageConvert:
            return "arrow.triangle.2.circlepath"
        }
    }

    var titleKey: String {
        switch self {
        case .pdfCompress:
            return "tool.pdfCompress.title"
        case .imagesToPDF:
            return "tool.imagesToPDF.title"
        case .pdfToImages:
            return "tool.pdfToImages.title"
        case .imageConvert:
            return "tool.imageConvert.title"
        }
    }

    var subtitleKey: String {
        switch self {
        case .pdfCompress:
            return "tool.pdfCompress.subtitle"
        case .imagesToPDF:
            return "tool.imagesToPDF.subtitle"
        case .pdfToImages:
            return "tool.pdfToImages.subtitle"
        case .imageConvert:
            return "tool.imageConvert.subtitle"
        }
    }
}

enum PDFCompressionLevel: String, CaseIterable, Identifiable {
    case balanced
    case smaller
    case bestQuality

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .balanced:
            return "compression.balanced"
        case .smaller:
            return "compression.smaller"
        case .bestQuality:
            return "compression.bestQuality"
        }
    }

    var scale: CGFloat {
        switch self {
        case .balanced:
            return 0.72
        case .smaller:
            return 0.52
        case .bestQuality:
            return 0.9
        }
    }

    var jpegQuality: CGFloat {
        switch self {
        case .balanced:
            return 0.66
        case .smaller:
            return 0.46
        case .bestQuality:
            return 0.82
        }
    }

    var suffix: String {
        switch self {
        case .balanced:
            return "balanced"
        case .smaller:
            return "small"
        case .bestQuality:
            return "quality"
        }
    }
}

enum ImageOutputFormat: String, CaseIterable, Identifiable {
    case jpeg
    case png
    case heic

    var id: String { rawValue }

    var fileExtension: String {
        switch self {
        case .jpeg:
            return "jpg"
        case .png:
            return "png"
        case .heic:
            return "heic"
        }
    }

    var title: String {
        rawValue.uppercased()
    }

    var type: UTType {
        switch self {
        case .jpeg:
            return .jpeg
        case .png:
            return .png
        case .heic:
            return .heic
        }
    }
}

struct ProcessedFile: Identifiable, Codable, Hashable {
    let id: UUID
    let tool: ToolKind
    let title: String
    let detail: String
    let fileName: String
    let byteSize: Int64
    let createdAt: Date

    init(
        id: UUID = UUID(),
        tool: ToolKind,
        title: String,
        detail: String,
        fileName: String,
        byteSize: Int64,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.tool = tool
        self.title = title
        self.detail = detail
        self.fileName = fileName
        self.byteSize = byteSize
        self.createdAt = createdAt
    }
}

extension ToolKind {
    var sampleDetailKey: String {
        switch self {
        case .pdfCompress, .imagesToPDF, .pdfToImages, .imageConvert:
            return "recent.demo.detail"
        }
    }
}
