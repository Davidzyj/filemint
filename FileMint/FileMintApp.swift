import SwiftUI

@main
struct FileMintApp: App {
    @StateObject private var appLocale = AppLocale()
    @StateObject private var fileStore = FileStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: fileStore)
                .environmentObject(appLocale)
                .task {
                    fileStore.load()
                }
        }
    }
}

