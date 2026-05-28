import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var locale: AppLocale
    @ObservedObject var store: FileStore

    let openRoute: (ToolRoute) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                tools
                recent
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .fileMintBackground()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    openRoute(.settings)
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(FileMintTheme.ink)
                }
                .accessibilityLabel(locale.text("nav.settings"))
            }
        }
        .accessibilityIdentifier("screen.home")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(FileMintTheme.mint)
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 3) {
                    Text(locale.text("app.title"))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(FileMintTheme.ink)
                        .minimumScaleFactor(0.8)
                    Text(locale.text("app.subtitle"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var tools: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(locale.text("section.tools"))
                .font(.headline)
                .foregroundStyle(FileMintTheme.ink)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(ToolKind.allCases) { tool in
                    ToolCard(tool: tool) {
                        openRoute(ToolRoute(tool: tool))
                    }
                }
            }
        }
    }

    private var recent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(locale.text("section.recent"))
                    .font(.headline)
                    .foregroundStyle(FileMintTheme.ink)
                Spacer()
                if !store.recentFiles.isEmpty {
                    Button(locale.text("button.clear")) {
                        store.clearHistory()
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(FileMintTheme.mint)
                }
            }

            let files = displayRecentFiles
            if files.isEmpty {
                Text(locale.text("recent.empty"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(FileMintTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                VStack(spacing: 10) {
                    ForEach(files) { file in
                        RecentFileRow(file: file)
                    }
                }
            }
        }
    }

    private var displayRecentFiles: [ProcessedFile] {
        if ScreenshotConfig.isEnabled, store.recentFiles.isEmpty {
            return [
                ProcessedFile(
                    tool: .pdfCompress,
                    title: locale.text("screenshot.sample.result"),
                    detail: locale.text("recent.demo.detail"),
                    fileName: "sample.pdf",
                    byteSize: 1_840_000,
                    createdAt: Date()
                )
            ]
        }
        return store.recentFiles
    }
}

struct ToolCard: View {
    @EnvironmentObject private var locale: AppLocale
    let tool: ToolKind
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: tool.iconName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(iconTint, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(locale.text(tool.titleKey))
                        .font(.headline)
                        .foregroundStyle(FileMintTheme.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                    Text(locale.text(tool.subtitleKey))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 156, alignment: .leading)
            .padding(14)
            .background(FileMintTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var iconTint: Color {
        switch tool {
        case .pdfCompress:
            return FileMintTheme.mint
        case .imagesToPDF:
            return FileMintTheme.blue
        case .pdfToImages:
            return FileMintTheme.coral
        case .imageConvert:
            return .purple
        }
    }
}

struct RecentFileRow: View {
    @EnvironmentObject private var locale: AppLocale
    let file: ProcessedFile

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: file.tool.iconName)
                .foregroundStyle(FileMintTheme.mint)
                .frame(width: 36, height: 36)
                .background(FileMintTheme.mint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(file.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FileMintTheme.ink)
                    .lineLimit(1)
                Text(file.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Text(locale.formattedBytes(file.byteSize))
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(14)
        .background(FileMintTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
