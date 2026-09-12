import SwiftUI

@main
@MainActor
struct EmpiricalWaterApp: App {
    var body: some Scene {
        WindowGroup("empirical water") {
            RootView()
                #if os(macOS)
                .frame(minWidth: 420, minHeight: 560)
                #endif
        }
        #if os(macOS)
        .defaultSize(width: 580, height: 780)
        .windowResizability(.contentMinSize)
        #endif

        #if os(macOS)
        Settings {
            SettingsView()
                .frame(width: 460, height: 430)
        }
        #endif
    }
}

struct RootView: View {
    @State private var appState = AppState()
    @AppStorage("forceDarkMode") private var forceDarkMode = false

    var body: some View {
        RecipeView()
            .environment(appState)
            .preferredColorScheme(forceDarkMode ? .dark : nil)
    }
}
