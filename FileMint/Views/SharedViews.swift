import SwiftUI
import UIKit
import QuickLook

enum FileMintTheme {
    static let mint = Color(red: 0.04, green: 0.62, blue: 0.48)
    static let ink = Color(red: 0.08, green: 0.11, blue: 0.14)
    static let blue = Color(red: 0.10, green: 0.36, blue: 0.86)
    static let coral = Color(red: 0.91, green: 0.27, blue: 0.22)
    static let surface = Color(.secondarySystemBackground)
    static let page = Color(.systemBackground)
}

struct PrimaryActionButton: View {
    let title: String
    let systemImage: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: systemImage)
                        .imageScale(.medium)
                }
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundStyle(.white)
            .background(FileMintTheme.mint, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

struct SecondaryActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .foregroundStyle(FileMintTheme.ink)
            .background(FileMintTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct InfoPill: View {
    let label: String
    let value: String
    var tint: Color = FileMintTheme.blue

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(FileMintTheme.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(tint.opacity(0.10), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct ResultCard: View {
    @EnvironmentObject private var locale: AppLocale

    let file: ProcessedFile
    let fileURL: URL

    @State private var isSharing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: file.tool.iconName)
                    .font(.title3)
                    .foregroundStyle(FileMintTheme.mint)
                    .frame(width: 42, height: 42)
                    .background(FileMintTheme.mint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(locale.text("status.complete"))
                        .font(.headline)
                        .foregroundStyle(FileMintTheme.ink)
                    Text(file.title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            HStack(spacing: 10) {
                InfoPill(label: locale.text("status.output"), value: file.detail, tint: FileMintTheme.mint)
                InfoPill(label: locale.text("status.size"), value: locale.formattedBytes(file.byteSize), tint: FileMintTheme.coral)
            }

            PrimaryActionButton(
                title: locale.text("button.share"),
                systemImage: "square.and.arrow.up",
                isLoading: false
            ) {
                isSharing = true
            }
        }
        .padding(16)
        .background(FileMintTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .sheet(isPresented: $isSharing) {
            ShareSheet(items: [fileURL])
        }
    }
}

struct ErrorBanner: View {
    @EnvironmentObject private var locale: AppLocale
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(FileMintTheme.coral)
            VStack(alignment: .leading, spacing: 3) {
                Text(locale.text("error.title"))
                    .font(.subheadline.weight(.semibold))
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(FileMintTheme.coral.opacity(0.10), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct SampleOutputView: View {
    @EnvironmentObject private var locale: AppLocale
    let tool: ToolKind

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: tool.iconName)
                    .font(.title3)
                    .foregroundStyle(FileMintTheme.mint)
                    .frame(width: 42, height: 42)
                    .background(FileMintTheme.mint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(locale.text("status.complete"))
                        .font(.headline)
                    Text(locale.text("screenshot.sample.result"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 10) {
                InfoPill(label: locale.text("status.output"), value: locale.text("recent.demo.detail"), tint: FileMintTheme.mint)
                InfoPill(label: locale.text("status.size"), value: "1.8 MB", tint: FileMintTheme.coral)
            }
        }
        .padding(16)
        .background(FileMintTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        context.coordinator.url = url
        uiViewController.reloadData()
    }

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        var url: URL

        init(url: URL) {
            self.url = url
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as NSURL
        }
    }
}

extension View {
    func fileMintBackground() -> some View {
        background(FileMintTheme.page.ignoresSafeArea())
    }
}
