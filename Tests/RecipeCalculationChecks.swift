import Foundation

private struct Expected: Decodable {
    let water: Waters
    let brew: BrewTypes
    let unit: Units
    let volume: Double
    let boosterPerLiter: Double
    let mask: Int
    let amounts: [Double]
    let gh: Double
    let kh: Double
    let tds: Double
}

private func require(_ condition: @autoclosure () -> Bool, _ message: String) {
    guard condition() else { fatalError(message) }
}

private func near(_ actual: Double, _ expected: Double, _ label: String) {
    require(actual.isFinite && abs(actual - expected) <= 1e-9 * max(1, abs(expected)),
            "\(label): expected \(expected), actual \(actual)")
}

@main
@MainActor
struct RecipeCalculationChecks {
    static func main() throws {
        let data = try Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
        let cases = try JSONDecoder().decode([Expected].self, from: data)
        require(!cases.isEmpty, "The upstream fixture must not be empty")
        var testedPresets = Set<String>()
        for expected in cases {
            let label = "\(expected.water)/\(expected.brew)/\(expected.volume) \(expected.unit)"
            guard let result = RecipeCalculator.calculate(
                water: expected.water, brew: expected.brew,
                volume: expected.volume, unit: expected.unit,
                boosterPerLiter: expected.boosterPerLiter
            ) else { fatalError("Missing supported recipe: \(label)") }
            for (index, ingredient) in Ingredient.allCases.enumerated() {
                let volumetric = expected.mask & (1 << index) != 0
                near(result.amount(for: ingredient).value(volumetric: volumetric),
                     expected.amounts[index], "\(label) \(ingredient) mask=\(expected.mask)")
            }
            near(result.minerals.gh, expected.gh, "\(label) GH")
            near(result.minerals.kh, expected.kh, "\(label) KH")
            near(result.minerals.tds, expected.tds, "\(label) TDS")
            near(Ingredient.allCases.reduce(0) { $0 + result.amount(for: $1).milliliters },
                 result.totalMilliliters, "\(label) total volume")
            testedPresets.insert("\(expected.water.rawValue)/\(expected.brew.rawValue)")
        }
        // Catch presets exposed by the app but omitted from the reference matrix.
        let supported = Set(Waters.allCases.flatMap { water in
            water.profile.recipes.map { "\(water.rawValue)/\($0.brew.rawValue)" }
        })
        require(testedPresets == supported, "Every published recipe must be exercised")

        // Independently checked regressions: old releases returned zero espresso
        // ingredients, used a 1.18 buffer density, and omitted buffer displacement.
        let espresso = RecipeCalculator.calculate(water: .spring, brew: .espresso, volume: 1, unit: .liter)!
        near(espresso.hardness.milliliters, 50, "Spring espresso hardness")
        near(espresso.buffer.grams, 2.064, "Spring espresso buffer mass")
        near(espresso.zeroWater.milliliters, 948, "Spring espresso dilution")
        let light = RecipeCalculator.calculate(water: .glacial, brew: .light_roast, volume: 1, unit: .liter)!
        near(light.buffer.grams, 0.3066, "Glacial buffer density")
        near(light.zeroWater.milliliters, 949.7, "Buffer displaces dilution water")
        near(light.booster.milliliters, 0, "Published presets do not add booster")
        let boosted = RecipeCalculator.calculate(water: .glacial, brew: .light_roast, volume: 1, unit: .liter, boosterPerLiter: 0.5)!
        near(boosted.booster.grams, 0.512, "Booster density")
        near(boosted.zeroWater.milliliters, 949.2, "Booster displaces dilution water")

        for volume in [-1.0, 0, .nan, .infinity, -.infinity, .greatestFiniteMagnitude] {
            require(RecipeCalculator.calculate(water: .glacial, brew: .light_roast, volume: volume, unit: .gallon) == nil,
                    "Reject invalid or overflowing volume: \(volume)")
        }
        for booster in [-1.0, .nan, .infinity, .greatestFiniteMagnitude, 1000] {
            require(RecipeCalculator.calculate(water: .glacial, brew: .light_roast, volume: 1, unit: .liter, boosterPerLiter: booster) == nil,
                    "Reject invalid or overfilled booster dose: \(booster)")
        }
        require(RecipeCalculator.calculate(water: .spring, brew: .acidity, volume: 1, unit: .liter) == nil,
                "Unsupported combinations must not produce a zero-ingredient recipe")
        require(RecipeCalculator.calculate(water: .aviary, brew: .espresso, volume: 1, unit: .liter) == nil,
                "Aviary only publishes Filter")

        let first = AppState()
        let second = AppState()
        first.unitVolume = 5
        first.water = .aviary
        require(first.brewType == .filter, "Changing water must select a supported brew")
        require(second.water == .glacial && second.unitVolume == 1, "Windows must have independent brewing sessions")
        first.water = .spring
        require(first.brewType == .light_roast, "Leaving Aviary must restore a supported brew")
        first.brewType = .espresso
        first.water = .glacial
        require(first.brewType == .espresso, "Preserve a brew supported by the next profile")
        first.unit = .milliliter
        near(first.unitVolume, 100, "Unit changes reset the volume within the slider range")
        first.unitVolume = 450
        first.unit = .milliliter
        near(first.unitVolume, 450, "Selecting the same unit must preserve volume")
        first.unit = .gallon
        near(first.unitVolume, 1, "Gallon default")
        first.boosterPerLiter = 1
        require(second.boosterPerLiter == 0, "Booster input must be session-local")

        print("Passed \(cases.count) upstream recipe comparisons across \(testedPresets.count) presets; regression, validation, and session-state checks passed.")
    }
}
