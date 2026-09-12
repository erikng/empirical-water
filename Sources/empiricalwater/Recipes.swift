import Foundation

enum BrewTypes: String, CaseIterable, Identifiable, Codable, Sendable {
    case acidity, light_roast, medium_roast, dark_roast, espresso, tea, filter
    var id: Self { self }

    var name: String {
        switch self {
        case .acidity: "Acidity++"
        case .light_roast: "Light Roast"
        case .medium_roast: "Medium Roast"
        case .dark_roast: "Dark Roast"
        case .espresso: "Espresso"
        case .tea: "Tea"
        case .filter: "Filter"
        }
    }
}

struct BrewRecipe: Identifiable, Sendable {
    let brew: BrewTypes
    let hardnessPerLiter: Double
    let bufferPerLiter: Double
    var id: BrewTypes { brew }
}

struct WaterProfile: Sendable {
    let description: String
    let ghPerML: Double
    let khPerML: Double
    let bufferKHPerML: Double
    let bufferDensity: Double
    let hardnessTDSPerML: Double
    let bufferTDSPerML: Double
    let recipes: [BrewRecipe]

    func recipe(for brew: BrewTypes) -> BrewRecipe? {
        recipes.first { $0.brew == brew }
    }
}

enum Waters: String, CaseIterable, Identifiable, Codable, Sendable {
    case glacial, spring, aviary
    var id: Self { self }
    var name: String { rawValue.capitalized }
    var defaultBrew: BrewTypes { self == .aviary ? .filter : .light_roast }

    var profile: WaterProfile {
        switch self {
        case .glacial: Self.glacialProfile
        case .spring: Self.springProfile
        case .aviary: Self.aviaryProfile
        }
    }

    // Current Water Calculator constants, refreshed 2026-09-12.
    // Reference/EmpiricalWater preserves the independent upstream data/formulas.
    private static let glacialProfile = WaterProfile(
        description: "Harmonious and lively, emphasizing clarity and complexity.",
        ghPerML: 34.62 / 50, khPerML: 15.76 / 50,
        bufferKHPerML: 27234 / 1000, bufferDensity: 1.022,
        hardnessTDSPerML: 46.956 / 50, bufferTDSPerML: 41365.369 / 1000,
        recipes: [
            BrewRecipe(brew: .acidity, hardnessPerLiter: 50, bufferPerLiter: 0),
            BrewRecipe(brew: .light_roast, hardnessPerLiter: 50, bufferPerLiter: 0.3),
            BrewRecipe(brew: .medium_roast, hardnessPerLiter: 50, bufferPerLiter: 1),
            BrewRecipe(brew: .dark_roast, hardnessPerLiter: 50, bufferPerLiter: 1.5),
            BrewRecipe(brew: .espresso, hardnessPerLiter: 50, bufferPerLiter: 1.5),
            BrewRecipe(brew: .tea, hardnessPerLiter: 50, bufferPerLiter: 0.5),
        ]
    )

    private static let springProfile = WaterProfile(
        description: "Concentrated and resonant, emphasizing body and richness.",
        ghPerML: 65.21 / 100, khPerML: 22.54 / 100,
        bufferKHPerML: 41552.5 / 1000, bufferDensity: 1.032,
        hardnessTDSPerML: 85.911 / 100, bufferTDSPerML: 59962.448 / 1000,
        recipes: [
            BrewRecipe(brew: .light_roast, hardnessPerLiter: 100, bufferPerLiter: 0),
            BrewRecipe(brew: .medium_roast, hardnessPerLiter: 100, bufferPerLiter: 1),
            BrewRecipe(brew: .dark_roast, hardnessPerLiter: 100, bufferPerLiter: 1.5),
            BrewRecipe(brew: .espresso, hardnessPerLiter: 50, bufferPerLiter: 2),
            BrewRecipe(brew: .tea, hardnessPerLiter: 100, bufferPerLiter: 1),
        ]
    )

    private static let aviaryProfile = WaterProfile(
        description: "Designed by Christopher Feran for Aviary and similar roasts. Use the current concentrate (batch 5 or later / no batch number).",
        ghPerML: 58.4 / 20, khPerML: 0,
        bufferKHPerML: 27 / 0.5, bufferDensity: 1.049,
        hardnessTDSPerML: 68.240 / 20, bufferTDSPerML: 90727 / 1000,
        recipes: [BrewRecipe(brew: .filter, hardnessPerLiter: 20, bufferPerLiter: 0.5)]
    )
}
