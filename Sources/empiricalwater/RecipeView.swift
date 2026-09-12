import SwiftUI

struct RecipeView: View {
    @Environment(AppState.self) private var appState
    @AppStorage("minimalButtons") private var minimalButtons = false
    @AppStorage("lastVersionLaunched") private var lastVersionLaunched = "0.0"

    var body: some View {
        @Bindable var appState = appState

        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 16) {
                        if !minimalButtons {
                            Image("Icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                                .accessibilityHidden(true)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("empirical water")
                                .font(.title2.bold())
                            Text(appState.water.profile.description)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 4)

                    Picker("Water", selection: $appState.water) {
                        ForEach(Waters.allCases) { water in
                            Text(water.name).tag(water)
                        }
                    }
                    .accessibilityIdentifier("waterPicker")

                    Picker("Brew", selection: $appState.brewType) {
                        ForEach(appState.water.profile.recipes) { recipe in
                            Text(recipe.brew.name).tag(recipe.brew)
                        }
                    }
                    .accessibilityIdentifier("brewPicker")
                }

                RecipeVolumeSection()
                RecipeResultsSection()

                #if os(iOS)
                Section {
                    DisclosureGroup("Optional Features", isExpanded: $appState.isOptionsExpanded) {
                        SettingsControls()
                    }
                }
                #endif

                Section("About These Recipes") {
                    Text("Buffer can also be added after brewing, one drop at a time to taste.")
                    Text("Concentrates containing silica are not suitable for coffee or espresso machines.")
                    Link("empirical water User Guide", destination: Self.guideURL)
                    Link("Purchase Concentrates", destination: Self.shopURL)
                    Text("Thanks to [Erik Gomez](https://github.com/erikng), the author of [Blossom Rain](https://github.com/erikng/Blossom-Rain), which this code is based on for our application.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .font(.callout)
            }
            .formStyle(.grouped)
            .navigationTitle("Brew Water")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            #if os(macOS)
            .toolbar {
                SettingsLink {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            #endif
        }
        .onAppear {
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0"
            if version.compare(lastVersionLaunched, options: .numeric) == .orderedDescending {
                appState.isOptionsExpanded = true
                lastVersionLaunched = version
            }
        }
    }

    private static let guideURL = URL(string: "https://empiricalwater.com/pages/user-guide")!
    private static let shopURL = URL(string: "https://empiricalwater.com")!
}

private struct RecipeVolumeSection: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        Section("Brew Volume") {
            Picker("Unit", selection: $appState.unit) {
                ForEach(Units.allCases) { unit in
                    Text(unit.name).tag(unit)
                }
            }
            .accessibilityIdentifier("unitPicker")
            LabeledContent("Volume") {
                Text("\(appState.unitVolume, format: .number.precision(.fractionLength(0...2))) \(appState.unit.symbol)")
                    .monospacedDigit()
            }
            Slider(value: $appState.unitVolume, in: appState.unit.range, step: appState.unit.step) {
                Text("Brew Volume")
            }
            .accessibilityValue("\(appState.unitVolume, format: .number) \(appState.unit.symbol)")
            .accessibilityIdentifier("volumeSlider")
        }
    }
}
