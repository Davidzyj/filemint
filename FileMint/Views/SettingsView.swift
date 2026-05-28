import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var locale: AppLocale
    @Environment(\.openURL) private var openURL
    @ObservedObject var store: FileStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                about
                links
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .fileMintBackground()
        .navigationTitle(locale.text("nav.settings"))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("screen.settings")
    }

    private var header: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(FileMintTheme.mint)
                Image(systemName: "leaf.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 4) {
                Text(locale.text("app.title"))
                    .font(.title2.weight(.bold))
                    .foregroundStyle(FileMintTheme.ink)
                Text(locale.text("settings.local.value"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var about: some View {
        VStack(spacing: 10) {
            SettingsRow(title: locale.text("settings.version"), value: AppConstants.versionString, systemImage: "number")
            SettingsRow(title: locale.text("settings.local"), value: locale.text("settings.local.value"), systemImage: "iphone")
        }
    }

    private var links: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(locale.text("settings.links"))
                .font(.headline)
                .foregroundStyle(FileMintTheme.ink)

            VStack(spacing: 10) {
                LinkButton(title: locale.text("button.privacy"), systemImage: "hand.raised.fill") {
                    openURL(locale.privacyURL())
                }
                LinkButton(title: locale.text("button.support"), systemImage: "questionmark.circle.fill") {
                    openURL(locale.supportURL())
                }
                LinkButton(title: locale.text("button.email"), systemImage: "envelope.fill") {
                    if let mailURL = URL(string: "mailto:\(AppConstants.supportEmail)") {
                        openURL(mailURL)
                    }
                }
            }
        }
    }
}

private struct SettingsRow: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(FileMintTheme.mint)
                .frame(width: 36, height: 36)
                .background(FileMintTheme.mint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FileMintTheme.ink)
                Text(value)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(FileMintTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct LinkButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(FileMintTheme.blue, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FileMintTheme.ink)
                Spacer()
                Image(systemName: "arrow.up.forward")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(FileMintTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
