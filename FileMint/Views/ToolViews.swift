import SwiftUI
import UniformTypeIdentifiers

struct PDFCompressView: View {
    @EnvironmentObject private var locale: AppLocale
    @ObservedObject var store: FileStore

    @State private var selectedURL: URL?
    @State private var selectedByteSize: Int64?
    @State private var compressionLevel: PDFCompressionLevel = .balanced
    @State private var previewSummary: ProcessingSummary?
    @State private var previewToken = UUID()
    @State private var result: ProcessedFile?
    @State private var errorMessage: String?
    @State private var isImporterPresented = false
    @State private var isProcessing = false
    @State private var isPreviewing = false
    @State private var isPreviewPresented = false

    var body: some View {
        ToolContainerView(
            title: locale.text("tool.pdfCompress.title"),
            subtitle: locale.text("tool.pdfCompress.subtitle"),
            tool: .pdfCompress
        ) {
            VStack(alignment: .leading, spacing: 16) {
                SelectedPDFPanel(name: selectedPDFName, size: selectedPDFSizeText)

                Picker(locale.text("compression.title"), selection: $compressionLevel) {
                    ForEach(PDFCompressionLevel.allCases) { level in
                        Text(locale.text(level.titleKey)).tag(level)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: compressionLevel) { _, _ in
                    updatePreview()
                }

                previewPanel

                SecondaryActionButton(title: locale.text("button.choosePDF"), systemImage: "doc.badge.plus") {
                    isImporterPresented = true
                }

                PrimaryActionButton(title: locale.text("button.compress"), systemImage: "doc.zipper", isLoading: isProcessing) {
                    process()
                }

                if let errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                if ScreenshotConfig.isEnabled {
                    SampleOutputView(tool: .pdfCompress)
                } else if let result {
                    ResultCard(file: result, fileURL: store.url(for: result))
                }
            }
        }
        .fileImporter(isPresented: $isImporterPresented, allowedContentTypes: [.pdf]) { response in
            switch response {
            case .success(let url):
                selectedURL = url
                selectedByteSize = FileProcessor.byteSize(of: url)
                result = nil
                updatePreview()
                errorMessage = nil
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
        .sheet(isPresented: $isPreviewPresented) {
            if let previewURL = previewSummary?.outputURL {
                QuickLookPreview(url: previewURL)
            }
        }
        .accessibilityIdentifier("screen.compress")
    }

    private var selectedPDFName: String {
        if ScreenshotConfig.isEnabled {
            return locale.text("screenshot.sample.pdf")
        }
        return selectedURL?.lastPathComponent ?? locale.text("status.ready")
    }

    private var selectedPDFSizeText: String {
        if ScreenshotConfig.isEnabled {
            return "3.5 MB"
        }
        guard let selectedByteSize else {
            return "-"
        }
        return locale.formattedBytes(selectedByteSize)
    }

    @ViewBuilder
    private var previewPanel: some View {
        if ScreenshotConfig.isEnabled {
            PreviewSizePanel(
                isLoading: false,
                sizeText: "1.8 MB",
                statusText: locale.text("status.previewReady"),
                canPreview: true
            ) {}
        } else if selectedURL != nil {
            PreviewSizePanel(
                isLoading: isPreviewing,
                sizeText: previewSummary.map { locale.formattedBytes($0.byteSize) } ?? "-",
                statusText: isPreviewing ? locale.text("status.previewUpdating") : locale.text("status.previewReady"),
                canPreview: previewSummary != nil && !isPreviewing
            ) {
                isPreviewPresented = true
            }
        }
    }

    private func updatePreview() {
        guard let selectedURL else {
            previewSummary = nil
            selectedByteSize = nil
            return
        }

        let token = UUID()
        previewToken = token
        previewSummary = nil
        isPreviewing = true
        errorMessage = nil

        Task { @MainActor in
            do {
                let outputURL = previewURL(for: selectedURL, level: compressionLevel)
                try FileManager.default.createDirectory(
                    at: outputURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try? FileManager.default.removeItem(at: outputURL)
                let summary = try FileProcessor.compressPDF(inputURL: selectedURL, level: compressionLevel, outputURL: outputURL)
                guard previewToken == token else {
                    try? FileManager.default.removeItem(at: outputURL)
                    return
                }
                previewSummary = summary
            } catch {
                guard previewToken == token else {
                    return
                }
                previewSummary = nil
                errorMessage = error.localizedDescription
            }

            if previewToken == token {
                isPreviewing = false
            }
        }
    }

    private func previewURL(for inputURL: URL, level: PDFCompressionLevel) -> URL {
        let name = inputURL.deletingPathExtension().lastPathComponent
        let fileName = "\(name)-\(level.suffix)-preview.pdf"
        return FileManager.default.temporaryDirectory
            .appendingPathComponent("FileMintPreviews", isDirectory: true)
            .appendingPathComponent(fileName)
    }

    private func process() {
        guard let selectedURL else {
            errorMessage = locale.text("error.noFile")
            return
        }

        isProcessing = true
        errorMessage = nil

        Task { @MainActor in
            defer { isProcessing = false }
            do {
                let baseName = selectedURL.deletingPathExtension().lastPathComponent + "-\(compressionLevel.suffix)"
                let outputURL = store.uniqueOutputURL(baseName: baseName, fileExtension: "pdf")
                let summary = try FileProcessor.compressPDF(inputURL: selectedURL, level: compressionLevel, outputURL: outputURL)
                result = store.add(
                    tool: .pdfCompress,
                    title: outputURL.lastPathComponent,
                    detail: locale.pdfCompressionDetail(percent: summary.value ?? 0),
                    outputURL: summary.outputURL
                )
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

private struct SelectedPDFPanel: View {
    @EnvironmentObject private var locale: AppLocale
    let name: String
    let size: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(FileMintTheme.mint)
                .frame(width: 36, height: 36)
                .background(FileMintTheme.mint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text(locale.text("status.selected"))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FileMintTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                InfoPill(label: locale.text("status.originalSize"), value: size, tint: FileMintTheme.blue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(FileMintTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct PreviewSizePanel: View {
    @EnvironmentObject private var locale: AppLocale
    let isLoading: Bool
    let sizeText: String
    let statusText: String
    let canPreview: Bool
    let previewAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "eye.fill")
                    .foregroundStyle(FileMintTheme.mint)
                    .frame(width: 34, height: 34)
                    .background(FileMintTheme.mint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text(statusText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(FileMintTheme.ink)
                    Text(locale.text("status.previewSize"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                if isLoading {
                    ProgressView()
                } else {
                    Text(sizeText)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(FileMintTheme.ink)
                }
            }

            SecondaryActionButton(title: locale.text("button.preview"), systemImage: "doc.text.magnifyingglass") {
                previewAction()
            }
            .disabled(!canPreview)
            .opacity(canPreview ? 1 : 0.55)
        }
        .padding(14)
        .background(FileMintTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct ImagesToPDFView: View {
    @EnvironmentObject private var locale: AppLocale
    @ObservedObject var store: FileStore

    @State private var selectedURLs: [URL] = []
    @State private var result: ProcessedFile?
    @State private var errorMessage: String?
    @State private var isImporterPresented = false
    @State private var isProcessing = false

    var body: some View {
        ToolContainerView(
            title: locale.text("tool.imagesToPDF.title"),
            subtitle: locale.text("tool.imagesToPDF.subtitle"),
            tool: .imagesToPDF
        ) {
            VStack(alignment: .leading, spacing: 16) {
                SelectedFilePanel(name: selectedImagesLabel)

                SecondaryActionButton(title: locale.text("button.chooseImages"), systemImage: "photo.on.rectangle.angled") {
                    isImporterPresented = true
                }

                PrimaryActionButton(title: locale.text("button.createPDF"), systemImage: "doc.badge.plus", isLoading: isProcessing) {
                    process()
                }

                if let errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                if ScreenshotConfig.isEnabled {
                    SampleOutputView(tool: .imagesToPDF)
                } else if let result {
                    ResultCard(file: result, fileURL: store.url(for: result))
                }
            }
        }
        .fileImporter(isPresented: $isImporterPresented, allowedContentTypes: [.image], allowsMultipleSelection: true) { response in
            switch response {
            case .success(let urls):
                selectedURLs = urls
                errorMessage = nil
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
        .accessibilityIdentifier("screen.imagesToPDF")
    }

    private var selectedImagesLabel: String {
        if ScreenshotConfig.isEnabled {
            return locale.text("screenshot.sample.images")
        }
        if selectedURLs.isEmpty {
            return locale.text("status.ready")
        }
        return "\(selectedURLs.count) \(locale.text("status.files"))"
    }

    private func process() {
        guard !selectedURLs.isEmpty else {
            errorMessage = locale.text("error.noImages")
            return
        }

        isProcessing = true
        errorMessage = nil

        Task { @MainActor in
            defer { isProcessing = false }
            do {
                let outputURL = store.uniqueOutputURL(baseName: "FileMint-Images", fileExtension: "pdf")
                let summary = try FileProcessor.imagesToPDF(imageURLs: selectedURLs, outputURL: outputURL)
                result = store.add(
                    tool: .imagesToPDF,
                    title: outputURL.lastPathComponent,
                    detail: locale.imageCountDetail(summary.value ?? selectedURLs.count),
                    outputURL: summary.outputURL
                )
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct PDFToImagesView: View {
    @EnvironmentObject private var locale: AppLocale
    @ObservedObject var store: FileStore

    @State private var selectedURL: URL?
    @State private var result: ProcessedFile?
    @State private var errorMessage: String?
    @State private var isImporterPresented = false
    @State private var isProcessing = false

    var body: some View {
        ToolContainerView(
            title: locale.text("tool.pdfToImages.title"),
            subtitle: locale.text("tool.pdfToImages.subtitle"),
            tool: .pdfToImages
        ) {
            VStack(alignment: .leading, spacing: 16) {
                SelectedFilePanel(name: selectedPDFName)

                SecondaryActionButton(title: locale.text("button.choosePDF"), systemImage: "doc.badge.plus") {
                    isImporterPresented = true
                }

                PrimaryActionButton(title: locale.text("button.exportImages"), systemImage: "photo.stack", isLoading: isProcessing) {
                    process()
                }

                if let errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                if ScreenshotConfig.isEnabled {
                    SampleOutputView(tool: .pdfToImages)
                } else if let result {
                    ResultCard(file: result, fileURL: store.url(for: result))
                }
            }
        }
        .fileImporter(isPresented: $isImporterPresented, allowedContentTypes: [.pdf]) { response in
            switch response {
            case .success(let url):
                selectedURL = url
                errorMessage = nil
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
        .accessibilityIdentifier("screen.pdfToImages")
    }

    private var selectedPDFName: String {
        if ScreenshotConfig.isEnabled {
            return locale.text("screenshot.sample.pdf")
        }
        return selectedURL?.lastPathComponent ?? locale.text("status.ready")
    }

    private func process() {
        guard let selectedURL else {
            errorMessage = locale.text("error.noFile")
            return
        }

        isProcessing = true
        errorMessage = nil

        Task { @MainActor in
            defer { isProcessing = false }
            do {
                let baseName = selectedURL.deletingPathExtension().lastPathComponent + "-images"
                let outputURL = store.uniqueOutputURL(baseName: baseName, fileExtension: "zip")
                let summary = try FileProcessor.pdfToImagesZip(inputURL: selectedURL, outputURL: outputURL)
                result = store.add(
                    tool: .pdfToImages,
                    title: outputURL.lastPathComponent,
                    detail: locale.pageCountDetail(summary.value ?? 0),
                    outputURL: summary.outputURL
                )
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct ImageConvertView: View {
    @EnvironmentObject private var locale: AppLocale
    @ObservedObject var store: FileStore

    @State private var selectedURL: URL?
    @State private var outputFormat: ImageOutputFormat = .jpeg
    @State private var result: ProcessedFile?
    @State private var errorMessage: String?
    @State private var isImporterPresented = false
    @State private var isProcessing = false

    var body: some View {
        ToolContainerView(
            title: locale.text("tool.imageConvert.title"),
            subtitle: locale.text("tool.imageConvert.subtitle"),
            tool: .imageConvert
        ) {
            VStack(alignment: .leading, spacing: 16) {
                SelectedFilePanel(name: selectedImageName)

                Picker(locale.text("format.title"), selection: $outputFormat) {
                    ForEach(ImageOutputFormat.allCases) { format in
                        Text(format.title).tag(format)
                    }
                }
                .pickerStyle(.segmented)

                SecondaryActionButton(title: locale.text("button.chooseImage"), systemImage: "photo.badge.plus") {
                    isImporterPresented = true
                }

                PrimaryActionButton(title: locale.text("button.convert"), systemImage: "arrow.triangle.2.circlepath", isLoading: isProcessing) {
                    process()
                }

                if let errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                if ScreenshotConfig.isEnabled {
                    SampleOutputView(tool: .imageConvert)
                } else if let result {
                    ResultCard(file: result, fileURL: store.url(for: result))
                }
            }
        }
        .fileImporter(isPresented: $isImporterPresented, allowedContentTypes: [.image]) { response in
            switch response {
            case .success(let url):
                selectedURL = url
                errorMessage = nil
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
        .accessibilityIdentifier("screen.imageConvert")
    }

    private var selectedImageName: String {
        if ScreenshotConfig.isEnabled {
            return "IMG_2048.HEIC"
        }
        return selectedURL?.lastPathComponent ?? locale.text("status.ready")
    }

    private func process() {
        guard let selectedURL else {
            errorMessage = locale.text("error.noFile")
            return
        }

        isProcessing = true
        errorMessage = nil

        Task { @MainActor in
            defer { isProcessing = false }
            do {
                let baseName = selectedURL.deletingPathExtension().lastPathComponent
                let outputURL = store.uniqueOutputURL(baseName: "\(baseName)-\(outputFormat.rawValue)", fileExtension: outputFormat.fileExtension)
                let summary = try FileProcessor.convertImage(inputURL: selectedURL, format: outputFormat, outputURL: outputURL)
                result = store.add(
                    tool: .imageConvert,
                    title: outputURL.lastPathComponent,
                    detail: summary.detail,
                    outputURL: summary.outputURL
                )
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

private struct ToolContainerView<Content: View>: View {
    @EnvironmentObject private var locale: AppLocale

    let title: String
    let subtitle: String
    let tool: ToolKind
    private let content: Content

    init(title: String, subtitle: String, tool: ToolKind, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.tool = tool
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 14) {
                    Image(systemName: tool.iconName)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(FileMintTheme.mint, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(FileMintTheme.ink)
                            .lineLimit(2)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                content
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .fileMintBackground()
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SelectedFilePanel: View {
    @EnvironmentObject private var locale: AppLocale
    let name: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(FileMintTheme.mint)
                .frame(width: 36, height: 36)
                .background(FileMintTheme.mint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(locale.text("status.selected"))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FileMintTheme.ink)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(FileMintTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
