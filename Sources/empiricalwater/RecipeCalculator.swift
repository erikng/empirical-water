import Foundation

enum Ingredient: String, CaseIterable, Identifiable, Sendable {
    case hardness, buffer, booster, zeroWater
    var id: Self { self }

    var name: String {
        switch self {
        case .hardness: "Hardness"
        case .buffer: "Buffer"
        case .booster: "Extraction Booster"
        case .zeroWater: "Zero TDS Water"
        }
    }
}

struct IngredientAmount: Sendable {
    let milliliters: Double
    let grams: Double
    func value(volumetric: Bool) -> Double { volumetric ? milliliters : grams }
}

struct MineralProfile: Sendable {
    let gh: Double
    let kh: Double
    let tds: Double
}

struct RecipeAmounts: Sendable {
    let totalMilliliters: Double
    let hardness: IngredientAmount
    let buffer: IngredientAmount
    let booster: IngredientAmount
    let zeroWater: IngredientAmount
    let minerals: MineralProfile

    func amount(for ingredient: Ingredient) -> IngredientAmount {
        switch ingredient {
        case .hardness: hardness
        case .buffer: buffer
        case .booster: booster
        case .zeroWater: zeroWater
        }
    }
}

enum RecipeCalculator {
    static func calculate(water: Waters, brew: BrewTypes, volume: Double, unit: Units,
                          boosterPerLiter: Double = 0) -> RecipeAmounts? {
        guard volume.isFinite, volume > 0,
              boosterPerLiter.isFinite, boosterPerLiter >= 0,
              let recipe = water.profile.recipe(for: brew) else { return nil }
        let totalML = unit.milliliters(for: volume)
        let liters = totalML / 1000
        guard totalML.isFinite, liters.isFinite, liters > 0 else { return nil }

        let profile = water.profile
        let hardness = liters * recipe.hardnessPerLiter
        let buffer = liters * recipe.bufferPerLiter
        let booster = liters * boosterPerLiter
        // Subtract every concentrate from final volume, in mL even for gram display.
        let zero = totalML - hardness - buffer - booster
        let bufferGrams = buffer * profile.bufferDensity
        let boosterGrams = booster * 1.024

        // Preserve the upstream arithmetic order, including normalization after scaling.
        let effectiveHardness = hardness / liters
        let effectiveBuffer = buffer / liters
        let effectiveBooster = booster / liters
        let gh = effectiveHardness * profile.ghPerML + effectiveBooster * (10582.64 / 1000)
        let kh = effectiveHardness * profile.khPerML + effectiveBuffer * profile.bufferKHPerML
        let tds = effectiveHardness * profile.hardnessTDSPerML
            + effectiveBuffer * profile.bufferTDSPerML + effectiveBooster * (11364.589 / 1000)
        guard [hardness, buffer, booster, zero, bufferGrams, boosterGrams, gh, kh, tds]
            .allSatisfy({ $0.isFinite && $0 >= 0 }) else { return nil }

        return RecipeAmounts(
            totalMilliliters: totalML,
            hardness: IngredientAmount(milliliters: hardness, grams: hardness),
            buffer: IngredientAmount(milliliters: buffer, grams: bufferGrams),
            booster: IngredientAmount(milliliters: booster, grams: boosterGrams),
            zeroWater: IngredientAmount(milliliters: zero, grams: zero),
            minerals: MineralProfile(gh: gh, kh: kh, tds: tds)
        )
    }
}
