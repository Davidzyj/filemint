import Foundation

@MainActor
final class FileStore: ObservableObject {
    @Published private(set) var recentFiles: [ProcessedFile] = []

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let fileManager = FileManager.default

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var historyURL: URL {
        documentsDirectory.appendingPathComponent("filemint-history.json")
    }

    var outputsDirectory: URL {
        documentsDirectory.appendingPathComponent("Processed", isDirectory: true)
    }

    init() {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func load() {
        ensureOutputDirectory()

        guard let data = try? Data(contentsOf: historyURL),
              let files = try? decoder.decode([ProcessedFile].self, from: data) else {
            recentFiles = []
            return
        }

        recentFiles = files.filter { fileManager.fileExists(atPath: url(for: $0).path) }
    }

    func add(tool: ToolKind, title: String, detail: String, outputURL: URL) -> ProcessedFile {
        ensureOutputDirectory()

        let file = ProcessedFile(
            tool: tool,
            title: title,
            detail: detail,
            fileName: outputURL.lastPathComponent,
            byteSize: byteSize(of: outputURL)
        )

        recentFiles.insert(file, at: 0)
        recentFiles = Array(recentFiles.prefix(50))
        save()
        return file
    }

    func clearHistory() {
        recentFiles = []
        save()
    }

    func url(for file: ProcessedFile) -> URL {
        outputsDirectory.appendingPathComponent(file.fileName)
    }

    func uniqueOutputURL(baseName: String, fileExtension: String) -> URL {
        ensureOutputDirectory()

        let cleanedBase = sanitizedFileName(baseName).isEmpty ? "FileMint" : sanitizedFileName(baseName)
        var candidate = outputsDirectory.appendingPathComponent("\(cleanedBase).\(fileExtension)")
        var index = 2

        while fileManager.fileExists(atPath: candidate.path) {
            candidate = outputsDirectory.appendingPathComponent("\(cleanedBase)-\(index).\(fileExtension)")
            index += 1
        }

        return candidate
    }

    func byteSize(of url: URL) -> Int64 {
        guard let attributes = try? fileManager.attributesOfItem(atPath: url.path),
              let size = attributes[.size] as? NSNumber else {
            return 0
        }

        return size.int64Value
    }

    private func ensureOutputDirectory() {
        try? fileManager.createDirectory(at: outputsDirectory, withIntermediateDirectories: true)
    }

    private func save() {
        guard let data = try? encoder.encode(recentFiles) else {
            return
        }

        try? data.write(to: historyURL, options: [.atomic])
    }

    private func sanitizedFileName(_ name: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        return name
            .components(separatedBy: invalid)
            .joined(separator: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
