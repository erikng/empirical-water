import SwiftUI

struct RecipeView: View {
    @Environment(AppState.self) private var appState
    @Environment(RecipeLibrary.self) private var library
    @AppStorage("minimalButtons") private var minimalButtons = false
    @AppStorage("lastVersionLaunched") private var lastVersionLaunched = "0.0"
    @FocusState private var focusedField: RecipeInputField?
    @State private var recipeToDelete: CustomRecipe?
    @State private var errorMessage: String?
    @State private var errorTitle: LocalizedStringKey = "Could Not Save Recipe"

    var body: some View {
        @Bindable var appState = appState
        @Bindable var library = library

        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 16) {
                        if !minimalButtons {
                            Image("Icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                                .accessibilityHidden(true)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("empirical water")
                                .font(.title2.bold())
                            if library.isPreset {
                                Text(appState.water.profile.description)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.vertical, 4)

                    Picker("Recipe", selection: Binding(
                        get: { library.selectedID },
                        set: {
                            focusedField = nil
                            library.select($0)
                        }
                    )) {
                        RecipePickerOptions()
                    }
                    .accessibilityIdentifier("recipePicker")

                    if library.isPreset {
                        Picker("Water", selection: $appState.water) {
                            ForEach(Waters.allCases) { water in
                                Text(water.name).tag(water)
                            }
                        }
                        .accessibilityIdentifier("waterPicker")

                        Picker("Brew", selection: $appState.brewType) {
                            ForEach(appState.water.profile.recipes) { recipe in
                                Text(recipe.brew.name).tag(recipe.brew)
                            }
                        }
                        .accessibilityIdentifier("brewPicker")
                    }
                }

                if let message = library.store.loadError {
                    Section { Text(message).foregroundStyle(.red) }
                }
                if library.isEditing {
                    CustomRecipeEditor(focusedField: $focusedField)
                }
                RecipeVolumeSection()
                RecipeResultsSection()

                #if os(iOS)
                Section {
                    DisclosureGroup("Optional Features", isExpanded: $appState.isOptionsExpanded) {
                        SettingsControls()
                    }
                }
                #endif

                Section("About These Recipes") {
                    Text("Buffer can also be added after brewing, one drop at a time to taste.")
                    Text("Concentrates containing silica are not suitable for coffee or espresso machines.")
                    Link("empirical water User Guide", destination: Self.guideURL)
                    Link("Purchase Concentrates", destination: Self.shopURL)
                    Text("Thanks to [Erik Gomez](https://github.com/erikng), the author of [Blossom Rain](https://github.com/erikng/Blossom-Rain), which this code is based on for our application.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .font(.callout)

                if library.isEditing {
                    Section {
                        TextField("Recipe name", text: $library.draft.name)
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .accessibilityIdentifier("customRecipeName")
                        TextField("Recipe description (optional)", text: $library.draft.description, axis: .vertical)
                            .lineLimit(3...6)
                            .focused($focusedField, equals: .description)
                            .submitLabel(.return)
                            .submitScope()
                            .accessibilityIdentifier("customRecipeDescription")
                    } header: {
                        Text("Recipe Information")
                    } footer: {
                        Text("Name your recipe to save it on this device.")
                    }

                    // Match Blossom Rain: actions remain last, even with invalid inputs.
                    Section {
                        VStack(spacing: 12) {
                            Button(action: saveCustomRecipe) {
                                Text(library.editingRecipeID == nil ? "Save Recipe" : "Save Changes")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .keyboardShortcut(.defaultAction)
                            .disabled(!library.canSaveDraft)
                            .accessibilityIdentifier("saveCustomRecipe")
                            Button("Cancel", role: .cancel) {
                                focusedField = nil
                                library.cancelEditing()
                            }
                            .buttonStyle(.borderless)
                            .keyboardShortcut(.cancelAction)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .accessibilityIdentifier("cancelCustomRecipe")
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color.clear)
                } else if let recipe = library.selectedSavedRecipe, !recipe.description.isEmpty {
                    Section("Recipe Information") {
                        Text(verbatim: recipe.description)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Brew Water")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onSubmit {
                if focusedField == .name {
                    focusedField = .description
                } else if focusedField != .description {
                    saveCustomRecipe()
                }
            }
            .toolbar {
                #if os(macOS)
                ToolbarItem {
                    SettingsLink {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                #endif
                if let saved = library.selectedSavedRecipe {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button {
                                focusedField = nil
                                library.editSelectedRecipe()
                            } label: {
                                Label("Edit Recipe", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                focusedField = nil
                                recipeToDelete = saved
                            } label: {
                                Label("Delete Recipe", systemImage: "trash")
                            }
                        } label: {
                            Label("Recipe Actions", systemImage: "square.and.pencil")
                        }
                        .accessibilityHint("Edit or delete this saved recipe.")
                        .accessibilityIdentifier("savedRecipeActions")
                    }
                }
                #if os(iOS)
                // One keyboard toolbar for the entire form, not one for each row.
                if focusedField != nil {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { focusedField = nil }
                            .accessibilityIdentifier("dismissRecipeKeyboard")
                    }
                }
                #endif
            }
            #if os(iOS)
            .scrollDismissesKeyboard(.immediately)
            #endif
        }
        .alert("Delete \(recipeToDelete?.name ?? "recipe")?", isPresented: Binding(
            get: { recipeToDelete != nil },
            set: { if !$0 { recipeToDelete = nil } }
        ), presenting: recipeToDelete) { recipe in
            Button("Cancel", role: .cancel) { recipeToDelete = nil }
            Button("Delete Recipe", role: .destructive) {
                do { try library.store.deleteRecipe(recipe.id) }
                catch {
                    errorTitle = "Could Not Delete Recipe"
                    errorMessage = error.localizedDescription
                }
                recipeToDelete = nil
            }
        }
        .alert(errorTitle, isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear {
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0"
            if version.compare(lastVersionLaunched, options: .numeric) == .orderedDescending {
                appState.isOptionsExpanded = true
                lastVersionLaunched = version
            }
        }
    }

    private func saveCustomRecipe() {
        guard library.canSaveDraft else { return }
        focusedField = nil
        do { try library.saveDraft() }
        catch {
            errorTitle = "Could Not Save Recipe"
            errorMessage = error.localizedDescription
        }
    }

    private static let guideURL = URL(string: "https://empiricalwater.com/pages/user-guide")!
    private static let shopURL = URL(string: "https://empiricalwater.com")!
}

private struct RecipeVolumeSection: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        Section("Brew Volume") {
            Picker("Unit", selection: $appState.unit) {
                ForEach(Units.allCases) { unit in
                    Text(unit.name).tag(unit)
                }
            }
            .accessibilityIdentifier("unitPicker")
            LabeledContent("Volume") {
                Text("\(appState.unitVolume, format: .number.precision(.fractionLength(0...2))) \(appState.unit.symbol)")
                    .monospacedDigit()
            }
            Slider(value: $appState.unitVolume, in: appState.unit.range, step: appState.unit.step) {
                Text("Brew Volume")
            }
            .accessibilityValue("\(appState.unitVolume, format: .number) \(appState.unit.symbol)")
            .accessibilityIdentifier("volumeSlider")
        }
    }
}
