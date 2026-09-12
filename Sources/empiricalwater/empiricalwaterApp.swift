import SwiftUI

@main
@MainActor
struct EmpiricalWaterApp: App {
    @State private var recipeStore = RecipeStore()

    var body: some Scene {
        WindowGroup("empirical water") {
            RootView(store: recipeStore)
                .environment(recipeStore)
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
                .environment(recipeStore)
                .frame(width: 460, height: 560)
        }
        #endif
    }
}

struct RootView: View {
    @State private var appState = AppState()
    @State private var library: RecipeLibrary
    @AppStorage("forceDarkMode") private var forceDarkMode = false

    init(store: RecipeStore) {
        _library = State(initialValue: RecipeLibrary(store: store))
    }

    var body: some View {
        RecipeView()
            .environment(appState)
            .environment(library)
            .preferredColorScheme(forceDarkMode ? .dark : nil)
    }
}
