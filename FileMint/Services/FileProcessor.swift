import Foundation
import ImageIO
import PDFKit
import UniformTypeIdentifiers
import UIKit

struct ProcessingSummary {
    let outputURL: URL
    let byteSize: Int64
    let detail: String
    let value: Int?

    init(outputURL: URL, byteSize: Int64, detail: String, value: Int? = nil) {
        self.outputURL = outputURL
        self.byteSize = byteSize
        self.detail = detail
        self.value = value
    }
}

enum FileProcessingError: LocalizedError {
    case unreadablePDF
    case unreadableImage
    case emptyPDF
    case emptyImages
    case unsupportedOutput

    var errorDescription: String? {
        switch self {
        case .unreadablePDF:
            return "The PDF could not be opened."
        case .unreadableImage:
            return "The image could not be opened."
        case .emptyPDF:
            return "The PDF has no pages."
        case .emptyImages:
            return "No images were selected."
        case .unsupportedOutput:
            return "This output format is not available on this device."
        }
    }
}

enum FileProcessor {
    static func compressPDF(inputURL: URL, level: PDFCompressionLevel, outputURL: URL) throws -> ProcessingSummary {
        try access(inputURL) { securedURL in
            guard let document = PDFDocument(url: securedURL) else {
                throw FileProcessingError.unreadablePDF
            }
            guard document.pageCount > 0, let firstPage = document.page(at: 0) else {
                throw FileProcessingError.emptyPDF
            }

            let firstSize = scaledPageSize(for: firstPage, scale: level.scale)
            let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: firstSize))

            try renderer.writePDF(to: outputURL) { context in
                for index in 0..<document.pageCount {
                    guard let page = document.page(at: index),
                          let image = rasterizedImage(for: page, scale: level.scale) else {
                        continue
                    }

                    let data = image.jpegData(compressionQuality: level.jpegQuality) ?? Data()
                    let compressedImage = UIImage(data: data) ?? image
                    let pageSize = image.size

                    context.beginPage(withBounds: CGRect(origin: .zero, size: pageSize), pageInfo: [:])
                    compressedImage.draw(in: CGRect(origin: .zero, size: pageSize))
                }
            }

            let originalSize = fileSize(inputURL)
            let outputSize = fileSize(outputURL)
            let saved = max(0, originalSize - outputSize)
            let percent = originalSize > 0 ? Int((Double(saved) / Double(originalSize)) * 100) : 0

            return ProcessingSummary(
                outputURL: outputURL,
                byteSize: outputSize,
                detail: percent > 0 ? "Saved \(percent)%" : "Compressed PDF",
                value: percent
            )
        }
    }

    static func imagesToPDF(imageURLs: [URL], outputURL: URL) throws -> ProcessingSummary {
        guard !imageURLs.isEmpty else {
            throw FileProcessingError.emptyImages
        }

        let images = try imageURLs.map { url in
            try access(url) { securedURL in
                guard let image = UIImage(contentsOfFile: securedURL.path) else {
                    throw FileProcessingError.unreadableImage
                }
                return image.normalizedForExport()
            }
        }

        guard let firstImage = images.first else {
            throw FileProcessingError.emptyImages
        }

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pdfPageSize(for: firstImage)))
        try renderer.writePDF(to: outputURL) { context in
            for image in images {
                let pageSize = pdfPageSize(for: image)
                let bounds = CGRect(origin: .zero, size: pageSize)
                context.beginPage(withBounds: bounds, pageInfo: [:])
                UIColor.white.setFill()
                context.cgContext.fill(bounds)
                image.draw(in: bounds)
            }
        }

        return ProcessingSummary(
            outputURL: outputURL,
            byteSize: fileSize(outputURL),
            detail: "\(images.count) image\(images.count == 1 ? "" : "s")",
            value: images.count
        )
    }

    static func pdfToImagesZip(inputURL: URL, outputURL: URL) throws -> ProcessingSummary {
        try access(inputURL) { securedURL in
            guard let document = PDFDocument(url: securedURL) else {
                throw FileProcessingError.unreadablePDF
            }
            guard document.pageCount > 0 else {
                throw FileProcessingError.emptyPDF
            }

            var writer = try ZipWriter(outputURL: outputURL)

            for index in 0..<document.pageCount {
                guard let page = document.page(at: index),
                      let image = rasterizedImage(for: page, scale: 1.35),
                      let data = image.jpegData(compressionQuality: 0.86) else {
                    continue
                }

                try writer.addFile(named: String(format: "page-%03d.jpg", index + 1), data: data)
            }

            try writer.close()

            return ProcessingSummary(
                outputURL: outputURL,
                byteSize: fileSize(outputURL),
                detail: "\(document.pageCount) page\(document.pageCount == 1 ? "" : "s")",
                value: document.pageCount
            )
        }
    }

    static func convertImage(inputURL: URL, format: ImageOutputFormat, outputURL: URL) throws -> ProcessingSummary {
        try access(inputURL) { securedURL in
            guard let image = UIImage(contentsOfFile: securedURL.path)?.normalizedForExport() else {
                throw FileProcessingError.unreadableImage
            }

            let data: Data
            switch format {
            case .jpeg:
                guard let jpegData = image.jpegData(compressionQuality: 0.88) else {
                    throw FileProcessingError.unsupportedOutput
                }
                data = jpegData
            case .png:
                guard let pngData = image.pngData() else {
                    throw FileProcessingError.unsupportedOutput
                }
                data = pngData
            case .heic:
                data = try heicData(from: image)
            }

            try data.write(to: outputURL, options: [.atomic])

            return ProcessingSummary(
                outputURL: outputURL,
                byteSize: fileSize(outputURL),
                detail: format.title
            )
        }
    }

    private static func access<T>(_ url: URL, work: (URL) throws -> T) throws -> T {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        return try work(url)
    }

    private static func fileSize(_ url: URL) -> Int64 {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attributes[.size] as? NSNumber else {
            return 0
        }
        return size.int64Value
    }

    private static func scaledPageSize(for page: PDFPage, scale: CGFloat) -> CGSize {
        let bounds = page.bounds(for: .mediaBox)
        return CGSize(
            width: max(1, bounds.width * scale),
            height: max(1, bounds.height * scale)
        )
    }

    private static func rasterizedImage(for page: PDFPage, scale: CGFloat) -> UIImage? {
        guard let pageRef = page.pageRef else {
            return nil
        }

        let pageBounds = page.bounds(for: .mediaBox)
        let size = scaledPageSize(for: page, scale: scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            UIColor.white.setFill()
            context.cgContext.fill(CGRect(origin: .zero, size: size))

            let cgContext = context.cgContext
            cgContext.saveGState()
            cgContext.translateBy(x: 0, y: size.height)
            cgContext.scaleBy(x: size.width / pageBounds.width, y: -size.height / pageBounds.height)
            cgContext.translateBy(x: -pageBounds.minX, y: -pageBounds.minY)
            cgContext.drawPDFPage(pageRef)
            cgContext.restoreGState()
        }
    }

    private static func pdfPageSize(for image: UIImage) -> CGSize {
        let maxSide: CGFloat = 1500
        let scale = min(1, maxSide / max(image.size.width, image.size.height))
        return CGSize(
            width: max(240, image.size.width * scale),
            height: max(240, image.size.height * scale)
        )
    }

    private static func heicData(from image: UIImage) throws -> Data {
        guard let cgImage = image.cgImage,
              let mutableData = CFDataCreateMutable(nil, 0),
              let destination = CGImageDestinationCreateWithData(
                mutableData,
                UTType.heic.identifier as CFString,
                1,
                nil
              ) else {
            throw FileProcessingError.unsupportedOutput
        }

        let options = [kCGImageDestinationLossyCompressionQuality as String: 0.86] as CFDictionary
        CGImageDestinationAddImage(destination, cgImage, options)

        guard CGImageDestinationFinalize(destination) else {
            throw FileProcessingError.unsupportedOutput
        }

        return mutableData as Data
    }
}

private extension UIImage {
    func normalizedForExport() -> UIImage {
        guard imageOrientation != .up else {
            return self
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false

        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
