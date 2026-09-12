import Foundation

/// Concentrate volumes for one liter of finished water, independent of display units.
struct CustomRecipe: Codable, Equatable, Identifiable, Sendable {
    var id = UUID()
    var name: String
    var description = ""
    var hardnessWater: Waters = .glacial
    var bufferWater: Waters = .glacial
    var hardnessPerLiter = 50.0
    var bufferPerLiter = 0.0
    var boosterPerLiter = 0.0

    var isValid: Bool {
        let doses = [hardnessPerLiter, bufferPerLiter, boosterPerLiter]
        return doses.allSatisfy { $0.isFinite && (0...1000).contains($0) }
            && doses.reduce(0, +) <= 1000
    }
}

struct CustomRecipeDraft {
    let id: UUID
    var name: String
    var description: String
    var hardnessWater: Waters
    var bufferWater: Waters
    private var values: [Ingredient: String]
    private let locale: Locale

    init(recipe: CustomRecipe? = nil, locale: Locale = .current) {
        id = recipe?.id ?? UUID()
        name = recipe?.name ?? ""
        description = recipe?.description ?? ""
        hardnessWater = recipe?.hardnessWater ?? .glacial
        bufferWater = recipe?.bufferWater ?? .glacial
        self.locale = locale
        values = [
            .hardness: recipe?.hardnessPerLiter ?? 50,
            .buffer: recipe?.bufferPerLiter ?? 0,
            .booster: recipe?.boosterPerLiter ?? 0
        ].mapValues { Self.format($0, locale: locale) }
    }

    subscript(ingredient: Ingredient) -> String {
        get { values[ingredient] ?? "" }
        set { values[ingredient] = newValue }
    }

    func value(for ingredient: Ingredient) -> Double? {
        let text = self[ingredient].trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: locale.decimalSeparator ?? ".", with: ".")
        guard let value = Double(text), value.isFinite, (0...1000).contains(value) else { return nil }
        return value
    }

    /// Keep concentrate sliders practical; larger typed doses expand the slider.
    func sliderMaximum(for ingredient: Ingredient) -> Double {
        let otherDoses = Ingredient.concentrates.filter { $0 != ingredient }.map { value(for: $0) ?? 0 }
        let available = max(0, 1000 - otherDoses.reduce(0, +))
        let usualMaximum: Double = ingredient == .hardness ? 1000 : ingredient == .buffer ? 50 : 15
        return min(available, max(usualMaximum, value(for: ingredient) ?? 0))
    }

    mutating func setSliderValue(_ value: Double, for ingredient: Ingredient) {
        guard value.isFinite, Ingredient.concentrates.contains(ingredient) else { return }
        let factor = ingredient == .hardness ? 1.0 : 10.0
        let maximum = (sliderMaximum(for: ingredient) * factor).rounded(.down) / factor
        let snapped = min(maximum, max(0, (value * factor).rounded() / factor))
        self[ingredient] = Self.format(snapped, locale: locale)
    }

    var recipe: CustomRecipe? {
        guard let hardness = value(for: .hardness), let buffer = value(for: .buffer),
              let booster = value(for: .booster) else { return nil }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let recipe = CustomRecipe(id: id, name: trimmedName.isEmpty ? "Custom Recipe" : trimmedName,
            description: description, hardnessWater: hardnessWater, bufferWater: bufferWater,
            hardnessPerLiter: hardness, bufferPerLiter: buffer, boosterPerLiter: booster)
        return recipe.isValid ? recipe : nil
    }

    private static func format(_ value: Double, locale: Locale) -> String {
        // Shortest round-tripping representation preserves typed precision across edits.
        let text = String(value)
        let compact = text.hasSuffix(".0") ? String(text.dropLast(2)) : text
        return compact.replacingOccurrences(of: ".", with: locale.decimalSeparator ?? ".")
    }
}
