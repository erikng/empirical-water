import SwiftUI

struct SettingsView: View {
    @AppStorage("forceDarkMode") private var forceDarkMode = false

    var body: some View {
        Form {
            SettingsControls()
        }
        .formStyle(.grouped)
        .preferredColorScheme(forceDarkMode ? .dark : nil)
    }
}

/// Existing preference keys are kept so upgrades retain measurement choices.
struct SettingsControls: View {
    @Environment(RecipeStore.self) private var store
    @AppStorage("forceDarkMode") private var forceDarkMode = false
    @AppStorage("minimalButtons") private var minimalButtons = false
    @AppStorage("showExtractionBooster") private var showExtractionBooster = false
    @AppStorage("useVolumetricMeasurementHardness") private var volumetricHardness = false
    @AppStorage("useVolumetricMeasurementBuffer") private var volumetricBuffer = false
    @AppStorage("useVolumetricMeasurementExtractionBooster") private var volumetricBooster = false
    @AppStorage("useVolumetricMeasurementZeroTDSWater") private var volumetricWater = false

    var body: some View {
        Section {
            Picker("Default Recipe", selection: Binding(
                get: { store.defaultID }, set: { store.setDefault($0) }
            )) {
                RecipePickerOptions(includeCustomEditor: false)
            }
            .accessibilityIdentifier("defaultRecipePicker")
        } header: {
            Text("Recipes")
        } footer: {
            Text("Used when the app opens a new brewing window. Saved recipes are stored on this device.")
        }

        Section {
            Toggle("Hardness in mL", isOn: $volumetricHardness)
            Toggle("Buffer in mL", isOn: $volumetricBuffer)
            Toggle("Extraction Booster in mL", isOn: $volumetricBooster)
            Toggle("Zero TDS Water in mL", isOn: $volumetricWater)
        } header: {
            Text("Measurement Units")
        } footer: {
            Text("Turn off a measurement toggle to show grams. Buffer and booster use their concentrate-specific densities.")
        }

        Section("Appearance and Options") {
            Toggle("Force Dark Mode", isOn: $forceDarkMode)
            Toggle("Compact Header", isOn: $minimalButtons)
            Toggle("Adjust Booster in Published Recipes", isOn: $showExtractionBooster)
                .accessibilityIdentifier("showExtractionBooster")
        }
    }
}
