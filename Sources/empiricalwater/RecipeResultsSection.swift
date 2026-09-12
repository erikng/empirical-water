import SwiftUI

struct RecipeResultsSection: View {
    @Environment(AppState.self) private var appState
    @AppStorage("showExtractionBooster") private var showExtractionBooster = false
    @AppStorage("useVolumetricMeasurementHardness") private var volumetricHardness = false
    @AppStorage("useVolumetricMeasurementBuffer") private var volumetricBuffer = false
    @AppStorage("useVolumetricMeasurementExtractionBooster") private var volumetricBooster = false
    @AppStorage("useVolumetricMeasurementZeroTDSWater") private var volumetricWater = false

    var body: some View {
        @Bindable var appState = appState

        if showExtractionBooster {
            Section {
                LabeledContent("Booster per Liter") {
                    Text("\(appState.boosterPerLiter, format: .number.precision(.fractionLength(1))) mL")
                        .monospacedDigit()
                }
                Slider(value: $appState.boosterPerLiter, in: 0...15, step: 0.1) {
                    Text("Extraction Booster per Liter")
                }
                .accessibilityValue("\(appState.boosterPerLiter, format: .number) milliliters per liter")
                .accessibilityIdentifier("boosterSlider")
            } header: {
                Text("Optional Extraction Booster")
            } footer: {
                Text("Published presets contain no booster. Adding it adjusts the recipe and reduces the zero TDS water by the same volume.")
            }
        }

        if let result = RecipeCalculator.calculate(
            water: appState.water, brew: appState.brewType,
            volume: appState.unitVolume, unit: appState.unit,
            boosterPerLiter: showExtractionBooster ? appState.boosterPerLiter : 0
        ) {
            Section {
                amountRow(.hardness, result: result, volumetric: volumetricHardness)
                amountRow(.buffer, result: result, volumetric: volumetricBuffer)
                if showExtractionBooster {
                    amountRow(.booster, result: result, volumetric: volumetricBooster)
                }
                amountRow(.zeroWater, result: result, volumetric: volumetricWater)
            } header: {
                Text(showExtractionBooster && appState.boosterPerLiter > 0 ? "Adjusted Brew Water Recipe" : "Brew Water Recipe")
            } footer: {
                Text("Add the concentrates, then add the zero TDS water shown to reach the selected final volume. Amounts are rounded only for display.")
            }

            Section("Mineral Profile") {
                mineralRow("Total Dissolved Solids", value: result.minerals.tds, unit: "mg/L")
                mineralRow("General Hardness (GH)", value: result.minerals.gh, unit: "mg/L as CaCO₃")
                mineralRow("Alkalinity (KH)", value: result.minerals.kh, unit: "mg/L as CaCO₃")
            }
        } else {
            Section {
                Text("Choose a supported recipe and a valid volume to calculate your brew water.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func amountRow(_ ingredient: Ingredient, result: RecipeAmounts, volumetric: Bool) -> some View {
        LabeledContent {
            Text("\(result.amount(for: ingredient).value(volumetric: volumetric), format: .number.precision(.fractionLength(2))) \(volumetric ? "mL" : "grams")")
                .fontWeight(.semibold)
                .monospacedDigit()
                .textSelection(.enabled)
        } label: {
            Text(ingredient.name)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("amount-\(ingredient.rawValue)")
    }

    private func mineralRow(_ title: LocalizedStringKey, value: Double, unit: String) -> some View {
        LabeledContent(title) {
            Text("\(value, format: .number.precision(.fractionLength(1))) \(unit)")
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}
