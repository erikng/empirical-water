import Foundation

private struct ExpectedCustom: Decodable {
    let hardnessWater: Waters
    let bufferWater: Waters
    let hardness: Double
    let buffer: Double
    let booster: Double
    let unit: Units
    let volume: Double
    let mask: Int
    let amounts: [Double]
    let gh: Double
    let kh: Double
    let tds: Double
}

@main
@MainActor
struct CustomRecipeChecks {
    static func main() throws {
        var failures = 0
        func check(_ condition: Bool, _ message: String) {
            if !condition { failures += 1; print("FAIL: \(message)") }
        }
        func near(_ actual: Double?, _ expected: Double, _ message: String) {
            check(actual.map { $0.isFinite && abs($0 - expected) < 1e-9 * max(1, abs(expected)) } == true, message)
        }
        func rejects(_ message: String, _ action: () throws -> Void) {
            do { try action(); check(false, message) } catch {}
        }

        let cases = try JSONDecoder().decode([ExpectedCustom].self,
            from: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1])))
        check(cases.count == 5184, "Exercise every concentrate pair, unit, and measurement preference")
        for expected in cases {
            let recipe = CustomRecipe(name: "Reference", hardnessWater: expected.hardnessWater,
                bufferWater: expected.bufferWater, hardnessPerLiter: expected.hardness,
                bufferPerLiter: expected.buffer, boosterPerLiter: expected.booster)
            let result = RecipeCalculator.calculate(custom: recipe, volume: expected.volume, unit: expected.unit)
            let label = "\(expected.hardnessWater)/\(expected.bufferWater)/\(expected.unit)/\(expected.volume)"
            for (index, ingredient) in Ingredient.allCases.enumerated() {
                near(result?.amount(for: ingredient).value(volumetric: expected.mask & (1 << index) != 0),
                     expected.amounts[index], "\(label): \(ingredient)")
            }
            near(result?.minerals.gh, expected.gh, "\(label): GH")
            near(result?.minerals.kh, expected.kh, "\(label): KH")
            near(result?.minerals.tds, expected.tds, "\(label): TDS")
        }

        let mixed = CustomRecipe(name: "Mixed", hardnessWater: .glacial, bufferWater: .spring,
                                 hardnessPerLiter: 50, bufferPerLiter: 1, boosterPerLiter: 0.5)
        let result = RecipeCalculator.calculate(custom: mixed, volume: 1, unit: .liter)
        near(result?.buffer.grams, 1.032, "Use the buffer concentrate's density, not the hardness concentrate's")
        near(result?.zeroWater.milliliters, 948.5, "Every custom concentrate displaces dilution water")
        near(result?.minerals.gh, 39.91132, "Booster contributes to hardness")
        near(result?.minerals.kh, 57.3125, "Hardness and buffer profiles contribute independently to alkalinity")
        for invalid in [-1.0, 0, .nan, .infinity, .greatestFiniteMagnitude] {
            check(RecipeCalculator.calculate(custom: mixed, volume: invalid, unit: .gallon) == nil,
                  "Reject invalid and overflowing batch volumes")
        }
        for invalid in [-1.0, .nan, .infinity, 1001] {
            var invalidRecipe = mixed
            invalidRecipe.bufferPerLiter = invalid
            check(RecipeCalculator.calculate(custom: invalidRecipe, volume: 1, unit: .liter) == nil,
                  "Reject invalid model data without relying on editor validation")
        }
        let full = CustomRecipe(name: "Full", hardnessPerLiter: 999.4, bufferPerLiter: 0.5, boosterPerLiter: 0.1)
        for unit in Units.allCases {
            let fullResult = RecipeCalculator.calculate(custom: full, volume: unit.initialVolume, unit: unit)
            near(fullResult?.zeroWater.milliliters, 0, "An exactly full decimal blend must survive scaling and floating-point roundoff")
        }

        var draft = CustomRecipeDraft()
        near(draft.recipe?.hardnessPerLiter, 50, "New custom recipe uses the website's default hardness")
        near(draft.recipe?.bufferPerLiter, 0, "New custom recipe starts with no buffer")
        for ingredient in Ingredient.concentrates {
            for invalid in ["", "-1", "1001", "nan", "inf", "1e309", "abc"] {
                var invalidDraft = CustomRecipeDraft()
                invalidDraft[ingredient] = invalid
                check(invalidDraft.recipe == nil, "Invalid \(ingredient) must hide results: \(invalid)")
            }
        }
        draft[.hardness] = "999"
        draft[.buffer] = "2"
        check(draft.recipe == nil, "Concentrates cannot exceed one liter of final water")
        draft[.buffer] = "1"
        near(draft.recipe.flatMap { RecipeCalculator.calculate(custom: $0, volume: 1, unit: .liter) }?.zeroWater.milliliters,
             0, "Exactly full mixtures are valid")
        draft = CustomRecipeDraft()
        draft.setSliderValue(83.250761, for: .hardness)
        near(draft.value(for: .hardness), 83, "Hardness slider snaps the stored amount")
        draft.setSliderValue(0.34, for: .buffer)
        near(draft.value(for: .buffer), 0.3, "Buffer slider snaps the stored amount")
        draft.setSliderValue(0.56, for: .booster)
        near(draft.value(for: .booster), 0.6, "Booster slider snaps the stored amount")
        draft[.hardness] = "40.25"
        draft.setSliderValue(.nan, for: .hardness)
        near(draft.value(for: .hardness), 40.25, "Typing retains precision; invalid slider values do not replace it")
        draft[.hardness] = "40.12345678901234"
        let reopenedDraft = CustomRecipeDraft(recipe: draft.recipe!)
        check(reopenedDraft.recipe?.hardnessPerLiter == draft.recipe?.hardnessPerLiter,
              "Opening a saved decimal dose for editing must not round it")
        draft[.hardness] = "999.65"
        draft[.buffer] = "0"
        draft[.booster] = "0"
        draft.setSliderValue(0.4, for: .buffer)
        near(draft.value(for: .buffer), 0.3, "Slider snapping cannot overfill the available water volume")
        var french = CustomRecipeDraft(locale: Locale(identifier: "fr_FR"))
        french[.buffer] = "0,55"
        near(french.recipe?.bufferPerLiter, 0.55, "Locale decimal input reaches the actual recipe")
        french.setSliderValue(0.34, for: .booster)
        near(french.recipe?.boosterPerLiter, 0.3, "Localized slider text parses back to the same dose")

        let suite = "EmpiricalWater.CustomRecipeChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = RecipeStore(defaults: defaults)
        let library = RecipeLibrary(store: store)
        let otherWindow = RecipeLibrary(store: store)
        library.select(RecipeLibrary.customSelectionID)
        let draftID = library.draft.id
        library.draft.description = "Keep this draft"
        library.select(RecipeLibrary.customSelectionID)
        check(library.draft.id == draftID && library.draft.description == "Keep this draft",
              "Reselecting the current custom editor cannot erase its draft")
        check(!library.canSaveDraft, "A new unnamed recipe cannot be saved")
        library.draft.name = "  Morning coffee  "
        library.draft.description = "First line\nSecond line **literal notes**"
        library.draft.hardnessWater = .aviary
        library.draft.bufferWater = .spring
        library.draft[.hardness] = "20.25"
        library.draft[.buffer] = "0.55"
        library.draft[.booster] = "0.15"
        try library.saveDraft()
        let saved = library.selectedSavedRecipe!
        let savedID = library.selectedID
        check(saved.name == "Morning coffee" && saved.description.contains("\n"), "Save trims the name and retains multiline notes")
        check(otherWindow.selectedID == RecipeLibrary.presetSelectionID && store.savedRecipes.count == 1,
              "Windows share saved recipes without sharing selections or drafts")
        store.setDefault(savedID)
        let reloaded = RecipeLibrary(store: RecipeStore(defaults: defaults))
        check(reloaded.currentRecipe == saved, "A saved recipe and its default survive reload")
        library.editSelectedRecipe()
        library.draft[.buffer] = "1.25"
        library.draft.description = "Unsaved"
        check(store.savedRecipes.first == saved, "Editing must not mutate saved data")
        library.cancelEditing()
        check(library.currentRecipe == saved, "Cancel restores the original recipe and notes")
        library.editSelectedRecipe()
        library.draft.name = "Renamed"
        library.draft.description = "Updated\nnotes"
        library.draft[.buffer] = "1.25"
        try library.saveDraft()
        check(store.savedRecipes.count == 1 && library.selectedID == savedID && store.defaultID == savedID,
              "Edits preserve recipe identity and default selection")
        check(RecipeStore(defaults: defaults).savedRecipes.first?.description == "Updated\nnotes", "Updated notes persist")
        library.select(RecipeLibrary.customSelectionID)
        library.draft.name = " renamed "
        rejects("Duplicate names cannot overwrite a saved recipe") { try library.saveDraft() }
        library.draft.name = "Second"
        library.draft[.hardness] = "nan"
        check(!library.canSaveDraft && library.currentRecipe == nil, "Invalid input hides stale preview and disables Save")
        rejects("Invalid data cannot be saved") { try library.saveDraft() }
        library.cancelEditing()
        check(library.selectedID == savedID, "Cancel an invalid new draft returns to the previous selection")
        otherWindow.select(RecipeLibrary.customSelectionID)
        otherWindow.draft.name = "Other window"
        try otherWindow.saveDraft()
        check(store.savedRecipes.count == 2, "Saving from a second window cannot lose the first window's recipe")
        otherWindow.select(savedID)
        try store.deleteRecipe(saved.id)
        check(store.defaultID == RecipeLibrary.presetSelectionID && otherWindow.selectedID == RecipeLibrary.presetSelectionID,
              "Deleting a custom default repairs every window's selection")
        check(RecipeStore(defaults: defaults).savedRecipes.count == 1, "Deletion persists")

        let corrupt = Data("unreadable JSON".utf8)
        defaults.set(corrupt, forKey: RecipeStore.storageKey)
        let damaged = RecipeStore(defaults: defaults)
        let blocked = RecipeLibrary(store: damaged)
        blocked.select(RecipeLibrary.customSelectionID)
        blocked.draft.name = "Do not overwrite"
        check(damaged.loadError != nil && !blocked.canSaveDraft, "Unreadable data is reported and prevents overwrites")
        rejects("Save cannot overwrite unreadable data") { try blocked.saveDraft() }
        check(defaults.data(forKey: RecipeStore.storageKey) == corrupt, "Unreadable stored data stays intact")
        defaults.set(try JSONEncoder().encode([saved, saved]), forKey: RecipeStore.storageKey)
        check(RecipeStore(defaults: defaults).loadError != nil, "Duplicate persisted identities are rejected")
        var overfilled = saved
        overfilled.hardnessPerLiter = 1000
        let invalidData = try JSONEncoder().encode([overfilled])
        defaults.set(invalidData, forKey: RecipeStore.storageKey)
        check(RecipeStore(defaults: defaults).loadError != nil && defaults.data(forKey: RecipeStore.storageKey) == invalidData,
              "Valid JSON containing invalid doses is preserved and reported")

        print("Custom recipes: \(cases.count) upstream comparisons; \(failures) failures in calculations, editing, persistence, and input checks.")
        exit(failures == 0 ? 0 : 1)
    }
}
