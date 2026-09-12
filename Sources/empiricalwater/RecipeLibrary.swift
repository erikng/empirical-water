import Foundation
import Observation

/// Shared saved data; individual windows keep their selections and drafts separately.
@MainActor
@Observable
final class RecipeStore {
    static let storageKey = "customRecipes.v1"
    private(set) var savedRecipes: [CustomRecipe] = []
    private(set) var defaultID = RecipeLibrary.presetSelectionID
    private(set) var loadError: String?
    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.storageKey) {
            do {
                let recipes = try JSONDecoder().decode([CustomRecipe].self, from: data)
                guard Set(recipes.map(\.id)).count == recipes.count,
                      recipes.allSatisfy({ $0.isValid && !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
                    throw RecipeLibraryError.invalidSavedData
                }
                savedRecipes = recipes
            } catch {
                loadError = RecipeLibraryError.invalidSavedData.localizedDescription
            }
        }
        if let stored = defaults.string(forKey: "defaultRecipe"), isSavedSelection(stored) {
            defaultID = stored
        }
    }

    func recipe(for selection: String) -> CustomRecipe? {
        savedRecipes.first { RecipeLibrary.selectionID(for: $0) == selection }
    }

    func isSavedSelection(_ id: String) -> Bool {
        id == RecipeLibrary.presetSelectionID || recipe(for: id) != nil
    }

    func setDefault(_ id: String) {
        guard isSavedSelection(id) else { return }
        defaults.set(id, forKey: "defaultRecipe")
        defaultID = id
    }

    func save(_ recipe: CustomRecipe, replacing id: UUID?) throws {
        guard recipe.isValid, !recipe.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RecipeLibraryError.invalidDraft
        }
        guard !savedRecipes.contains(where: {
            $0.id != id && $0.name.localizedCaseInsensitiveCompare(recipe.name) == .orderedSame
        }) else { throw RecipeLibraryError.duplicateName }
        var updated = savedRecipes
        if let id {
            guard recipe.id == id, let index = updated.firstIndex(where: { $0.id == id }) else {
                throw RecipeLibraryError.missingRecipe
            }
            updated[index] = recipe
        } else {
            guard !updated.contains(where: { $0.id == recipe.id }) else { throw RecipeLibraryError.duplicateIdentity }
            updated.append(recipe)
        }
        try persist(updated)
    }

    func deleteRecipe(_ id: UUID) throws {
        guard let recipe = savedRecipes.first(where: { $0.id == id }) else { return }
        try persist(savedRecipes.filter { $0.id != id })
        if defaultID == RecipeLibrary.selectionID(for: recipe) {
            setDefault(RecipeLibrary.presetSelectionID)
        }
    }

    private func persist(_ recipes: [CustomRecipe]) throws {
        guard loadError == nil else { throw RecipeLibraryError.invalidSavedData }
        let data = try JSONEncoder().encode(recipes)
        defaults.set(data, forKey: Self.storageKey)
        savedRecipes = recipes
    }
}

@MainActor
@Observable
final class RecipeLibrary {
    static let presetSelectionID = "preset"
    static let customSelectionID = "custom"
    let store: RecipeStore
    private var selection: String
    private var previousSelection: String
    private(set) var editingRecipeID: UUID?
    var draft = CustomRecipeDraft()

    init(store: RecipeStore) {
        self.store = store
        selection = store.defaultID
        previousSelection = store.defaultID
    }

    static func selectionID(for recipe: CustomRecipe) -> String { "saved:\(recipe.id.uuidString)" }

    var selectedID: String {
        if selection == Self.customSelectionID { return selection }
        return store.isSavedSelection(selection) ? selection : store.defaultID
    }

    var isEditing: Bool { selectedID == Self.customSelectionID }
    var isPreset: Bool { selectedID == Self.presetSelectionID }
    var selectedSavedRecipe: CustomRecipe? { store.recipe(for: selectedID) }
    var currentRecipe: CustomRecipe? { isEditing ? draft.recipe : selectedSavedRecipe }

    var canSaveDraft: Bool {
        isEditing && store.loadError == nil && draft.recipe != nil &&
            !draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func select(_ id: String) {
        guard id != selectedID else { return }
        if id == Self.customSelectionID {
            previousSelection = selectedID
            editingRecipeID = nil
            draft = CustomRecipeDraft()
            selection = id
        } else if store.isSavedSelection(id) {
            editingRecipeID = nil
            selection = id
        }
    }

    func editSelectedRecipe() {
        guard let recipe = selectedSavedRecipe else { return }
        previousSelection = selectedID
        editingRecipeID = recipe.id
        draft = CustomRecipeDraft(recipe: recipe)
        selection = Self.customSelectionID
    }

    func cancelEditing() {
        selection = store.isSavedSelection(previousSelection) ? previousSelection : store.defaultID
        editingRecipeID = nil
    }

    func saveDraft() throws {
        guard canSaveDraft, let recipe = draft.recipe else { throw RecipeLibraryError.invalidDraft }
        try store.save(recipe, replacing: editingRecipeID)
        selection = Self.selectionID(for: recipe)
        editingRecipeID = nil
    }
}

private enum RecipeLibraryError: LocalizedError {
    case invalidDraft, duplicateName, duplicateIdentity, missingRecipe, invalidSavedData

    var errorDescription: String? {
        switch self {
        case .invalidDraft:
            "Enter a recipe name and valid concentrate amounts totaling no more than 1,000 mL per liter."
        case .duplicateName:
            "A saved recipe already has that name. Choose a different name."
        case .duplicateIdentity:
            "This recipe has already been saved. Select it to edit it."
        case .missingRecipe:
            "This recipe is no longer available to update. Cancel to return to your recipes."
        case .invalidSavedData:
            "Saved recipes could not be read. Your stored data has been kept intact."
        }
    }
}
