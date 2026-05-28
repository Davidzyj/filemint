import SwiftUI

struct ContentView: View {
    @ObservedObject var store: FileStore
    @State private var path: [ToolRoute]

    init(store: FileStore) {
        self.store = store
        _path = State(initialValue: ScreenshotConfig.initialRoute.map { [$0] } ?? [])
    }

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(store: store, openRoute: openRoute)
                .navigationDestination(for: ToolRoute.self) { route in
                    destination(for: route)
                }
        }
    }

    private func openRoute(_ route: ToolRoute) {
        path.append(route)
    }

    @ViewBuilder
    private func destination(for route: ToolRoute) -> some View {
        switch route {
        case .pdfCompress:
            PDFCompressView(store: store)
        case .imagesToPDF:
            ImagesToPDFView(store: store)
        case .pdfToImages:
            PDFToImagesView(store: store)
        case .imageConvert:
            ImageConvertView(store: store)
        case .settings:
            SettingsView(store: store)
        }
    }
}
