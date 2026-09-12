import Foundation

enum Ingredient: String, CaseIterable, Identifiable, Sendable {
    case hardness, buffer, booster, zeroWater
    static let concentrates: [Self] = [.hardness, .buffer, .booster]
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

        let hardness = liters * recipe.hardnessPerLiter
        let buffer = liters * recipe.bufferPerLiter
        let booster = liters * boosterPerLiter
        return amounts(hardnessProfile: water.profile, bufferProfile: water.profile,
                       totalML: totalML, hardness: hardness, buffer: buffer, booster: booster)
    }

    static func calculate(custom recipe: CustomRecipe, volume: Double, unit: Units) -> RecipeAmounts? {
        guard recipe.isValid, volume.isFinite, volume > 0 else { return nil }
        let totalML = unit.milliliters(for: volume)
        let liters = totalML / 1000
        guard totalML.isFinite, liters.isFinite, liters > 0 else { return nil }
        return amounts(hardnessProfile: recipe.hardnessWater.profile, bufferProfile: recipe.bufferWater.profile,
                       totalML: totalML, hardness: liters * recipe.hardnessPerLiter,
                       buffer: liters * recipe.bufferPerLiter, booster: liters * recipe.boosterPerLiter)
    }

    private static func amounts(hardnessProfile: WaterProfile, bufferProfile: WaterProfile,
                                totalML: Double, hardness: Double, buffer: Double, booster: Double) -> RecipeAmounts? {
        let liters = totalML / 1000
        // Subtract every concentrate from final volume, in mL even for gram display.
        let remainder = totalML - hardness - buffer - booster
        // An exactly full blend can round infinitesimally below zero after scaling.
        guard remainder >= -totalML * 1e-12 else { return nil }
        let zero = max(0, remainder)
        let bufferGrams = buffer * bufferProfile.bufferDensity
        let boosterGrams = booster * 1.024

        // Preserve the upstream arithmetic order, including normalization after scaling.
        let effectiveHardness = hardness / liters
        let effectiveBuffer = buffer / liters
        let effectiveBooster = booster / liters
        let gh = effectiveHardness * hardnessProfile.ghPerML + effectiveBooster * (10582.64 / 1000)
        let kh = effectiveHardness * hardnessProfile.khPerML + effectiveBuffer * bufferProfile.bufferKHPerML
        let tds = effectiveHardness * hardnessProfile.hardnessTDSPerML
            + effectiveBuffer * bufferProfile.bufferTDSPerML + effectiveBooster * (11364.589 / 1000)
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
