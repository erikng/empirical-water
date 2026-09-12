import SwiftUI

enum RecipeInputField: Hashable {
    case name, description
    case concentrate(Ingredient)
}

struct CustomRecipeEditor: View {
    @Environment(RecipeLibrary.self) private var library
    @FocusState.Binding var focusedField: RecipeInputField?

    var body: some View {
        @Bindable var library = library

        Section {
            Picker("Hardness Concentrate", selection: $library.draft.hardnessWater) {
                ForEach(Waters.allCases) { water in
                    Text(water.name).tag(water)
                }
            }
            .accessibilityIdentifier("customHardnessProfile")
            Picker("Buffer Concentrate", selection: $library.draft.bufferWater) {
                ForEach(Waters.allCases) { water in
                    Text(water.name).tag(water)
                }
            }
            .accessibilityIdentifier("customBufferProfile")

            ForEach(Ingredient.concentrates) { ingredient in
                VStack(alignment: .leading) {
                    HStack {
                        Text(ingredient.name)
                        Spacer()
                        TextField("mL per liter", text: Binding(
                            get: { library.draft[ingredient] },
                            set: { library.draft[ingredient] = $0 }
                        ))
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .multilineTextAlignment(.trailing)
                        .frame(minWidth: 60, maxWidth: 120)
                        .focused($focusedField, equals: .concentrate(ingredient))
                        .accessibilityLabel("\(ingredient.name) in milliliters per liter")
                        .accessibilityIdentifier("custom-\(ingredient.rawValue)")
                        Text("mL/L").foregroundStyle(.secondary)
                    }

                    let maximum = library.draft.sliderMaximum(for: ingredient)
                    if maximum > 0 {
                        // Continuous native sliders avoid hundreds of OS 26 tick marks.
                        // The binding snaps the dose itself; typed input retains precision.
                        Slider(value: Binding(
                            get: { min(maximum, library.draft.value(for: ingredient) ?? 0) },
                            set: {
                                focusedField = nil
                                library.draft.setSliderValue($0, for: ingredient)
                            }
                        ), in: 0...maximum)
                        .accessibilityLabel("\(ingredient.name) per liter")
                        .accessibilityValue("\(library.draft[ingredient]) milliliters per liter")
                        .accessibilityIdentifier("custom-\(ingredient.rawValue)-slider")
                    }

                    if library.draft.value(for: ingredient) == nil {
                        Text("Enter a number from 0 to 1,000.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }

            if Ingredient.concentrates.allSatisfy({ library.draft.value(for: $0) != nil }),
               library.draft.recipe == nil {
                Text("The concentrate amounts together must not exceed 1,000 mL per liter.")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        } header: {
            Text(library.editingRecipeID == nil ? "Custom Recipe" : "Edit Custom Recipe")
        } footer: {
            Text("Enter concentrate amounts in milliliters for 1 liter of finished water. Brew Volume scales these amounts for your batch. Results use your measurement preferences; zero TDS water fills the remaining volume.")
        }
    }
}

struct RecipePickerOptions: View {
    @Environment(RecipeStore.self) private var store
    var includeCustomEditor = true

    var body: some View {
        Text("Published Recipes").tag(RecipeLibrary.presetSelectionID)
        if !store.savedRecipes.isEmpty {
            Section("Saved Recipes") {
                ForEach(store.savedRecipes) { recipe in
                    Text(verbatim: recipe.name).tag(RecipeLibrary.selectionID(for: recipe))
                }
            }
        }
        if includeCustomEditor {
            Text("Custom Recipe").tag(RecipeLibrary.customSelectionID)
        }
    }
}
