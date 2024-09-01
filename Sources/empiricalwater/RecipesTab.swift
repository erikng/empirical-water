//
//  RecipesTab.swift
//  empirical water
//
//  Created by Erik Gomez on 08/23/24.
//

import SwiftUI

struct RecipesTab: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("useManualVolumeInput") var useManualVolumeInput: Bool = false
    @AppStorage("volumeInputStepper") var volumeInputStepper: Double = 25.0
#if !SKIP
    @FocusState private var keyboardIsFocused: Bool
#endif
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Waters", selection: $appState.water) {
                        ForEach(Waters.allCases) { water in
                            Text(water.selectedWater.name)
                                .tag(water)
                        }
                    }
                    Picker("Brew Types", selection: $appState.brewType) {
                        ForEach(BrewTypes.allCases) { brewtype in
                            Text(brewtype.selectedBrewType.name)
                                .tag(brewtype)
                        }
                    }
                }
                
                Section {
                    Picker("Unit", selection: $appState.unit) {
                        ForEach(Units.allCases) { unit in
                            Text(unit.selectedUnit.name)
                                .tag(unit)
                        }
                    }
                    
                    if useManualVolumeInput {
                        HStack {
                            TextField(text: $appState.unitVolumeString) {
                                Text(appState.unitText)
                            }
#if !os(macOS)
                            .keyboardType(.numberPad)
#endif
                            
#if !SKIP
                            .focused($keyboardIsFocused)
                            .toolbar {
                                ToolbarItem(placement: .keyboard) {
                                    HStack {
                                        Spacer()
                                        Button("Close", systemImage: "checkmark.circle.fill", action: {
                                            keyboardIsFocused = false
                                        })
                                        .buttonStyle(.borderedProminent)
                                        .tint(.green)
                                    }
                                }
                            }
#endif
                        }
                    } else {
                        HStack {
                            if appState.unit == .milliliter {
                                Slider(
                                    value: $appState.unitVolume,
                                    in: 0.0...appState.unit.selectedUnit.maxStep,
                                    step: volumeInputStepper
                                )
                            } else {
                                Slider(
                                    value: $appState.unitVolume,
                                    in: 0.0...appState.unit.selectedUnit.maxStep,
                                    step: appState.unit.selectedUnit.initialStep
                                )
                            }
                            Text(String(Int(appState.unitVolume)))
                        }
                    }
                } header: {
                    Text("Volume")
                } footer: {}
                
                Section {
                    HStack {
                        Text(appState.water == .glacial ? "Glacial Hardness" : "Spring Hardness")
                        Spacer()
                        let hardnessValue: String = {
                            var volumeCalculation: Double
                            if appState.unit == .milliliter {
                                volumeCalculation = appState.unitVolume / 1000.00
                            } else if appState.unit == .liter {
                                volumeCalculation = appState.unitVolume
                            } else {
                                volumeCalculation = appState.unitVolume * 3.785
                            }
                            if appState.water == .glacial {
                                let value = appState.brewTypeGlacialHardness * volumeCalculation
                                return String(format: "%.2f", value)
                            } else if appState.water == .spring {
                                let value = appState.brewTypeSpringHardness * volumeCalculation
                                return String(format: "%.2f", value)
                            } else {
                                return ""
                            }
                        }()
                        Text("\(hardnessValue) mL")
                            .bold()
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color(red: 21.0/255.0, green: 67.0/255.0, blue: 109.0/255.0))
                    //.listRowBackground(Color(red: 47.0/255.0, green: 79.0/255.0, blue: 140.0/255.0))
                    
                    HStack {
                        Text(appState.water == .glacial ? "Glacial Buffer" : "Spring Buffer")
                        Spacer()
                        let bufferValue: String = {
                            var volumeCalculation: Double
                            if appState.unit == .milliliter {
                                volumeCalculation = appState.unitVolume / 1000.00
                            } else if appState.unit == .liter {
                                volumeCalculation = appState.unitVolume
                            } else {
                                volumeCalculation = appState.unitVolume * 3.785
                            }
                            if appState.water == .glacial {
                                let value = appState.brewTypeGlacialBuffer * volumeCalculation
                                return String(format: "%.2f", value)
                            } else if appState.water == .spring {
                                let value = appState.brewTypeSpringBuffer * volumeCalculation
                                return String(format: "%.2f", value)
                            } else {
                                return ""
                            }
                        }()
                        Text("\(bufferValue) grams")
                            .bold()
                    }
                    .foregroundColor(.white)
                    // .listRowBackground(Color(red: 0.0/255.0, green: 199.0/255.0, blue: 255.0/255.0))
                    .listRowBackground(Color(red: 21.0/255.0, green: 67.0/255.0, blue: 109.0/255.0))
                    //.listRowBackground(Color(red: 88.0/255.0, green: 197.0/255.0, blue: 250.0/255.0))
                    
                    HStack {
                        Text("Optional: Extraction Booster")
                        Spacer()
                        let extractionBoosterValue: String = {
                            var volumeCalculation: Double
                            if appState.unit == .milliliter {
                                volumeCalculation = appState.unitVolume / 1000.00
                            } else if appState.unit == .liter {
                                volumeCalculation = appState.unitVolume
                            } else {
                                volumeCalculation = appState.unitVolume * 3.785
                            }
                            if appState.water == .glacial {
                                let value = appState.brewTypeGlacialExtrationBooster * volumeCalculation
                                return String(format: "%.2f", value)
                            } else if appState.water == .spring {
                                let value = appState.brewTypeSpringExtrationBooster * volumeCalculation
                                return String(format: "%.2f", value)
                            } else {
                                return ""
                            }
                        }()
                        Text("\(extractionBoosterValue) grams")
                            .bold()
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color(red: 21.0/255.0, green: 67.0/255.0, blue: 109.0/255.0))
                    //.listRowBackground(Color(red: 172.0/255.0, green: 85.0/255.0, blue: 95.0/255.0))
                    
                    HStack {
                        Text("Zero TDS Water")
                        Spacer()
                        let zeroTDSWater: String = {
                            var volumeCalculation: Double
                            if appState.unit == .milliliter {
                                volumeCalculation = appState.unitVolume / 1000.00
                            } else if appState.unit == .liter {
                                volumeCalculation = appState.unitVolume
                            } else {
                                volumeCalculation = appState.unitVolume * 3.785
                            }
                            if appState.water == .glacial {
                                let value = 950 * volumeCalculation
                                return String(format: "%.2f", value)
                            } else if appState.water == .spring {
                                if appState.brewType.selectedBrewType.name == "Espresso" {
                                    return "0"
                                } else {
                                    let value = 900 * volumeCalculation
                                    return String(format: "%.2f", value)
                                }
                            } else {
                                return ""
                            }
                        }()
                        Text("\(zeroTDSWater) mL")
                            .bold()
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color.gray)
                    //.listRowBackground(Color(red: 21.0/255.0, green: 60.0/255.0, blue: 96.0/255.0))
                    //.listRowBackground(Color(red: 21.0/255.0, green: 67.0/255.0, blue: 109.0/255.0))
                    
                    HStack {
                        Text("**Note:** For best accuracy, rely primarily on the 0.50 mL fill line for measuring buffer. For higher intensity and acidity, use less buffer. For lower intensity and acidity, use more buffer.")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Formula")
                        .padding(.top)
                } footer: {}
                
                Section {
                    HStack {
                        if !appState.waterDescription.isEmpty {
                            Text(LocalizedStringKey(appState.waterDescription))
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Recipe Information")
                } footer: {
                    HStack(spacing: 0) {
                        Text("Purchase these concentrates at ")
                            .foregroundColor(.secondary)
                        
                        Link("empirical", destination: URL(string: "https://empiricalwater.com")!)
                            .bold()
                            .foregroundColor(Color(red: 21.0/255.0, green: 67.0/255.0, blue: 109.0/255.0))

                        Text(" ")
                            .foregroundColor(.secondary)
                        
                        Link("water", destination: URL(string: "https://empiricalwater.com")!)
                            .bold()
                            .foregroundColor(Color(red: 0.0/255.0, green: 199.0/255.0, blue: 255.0/255.0))
                    }
                    .font(.footnote)
                    .padding(.top)
                }
            }
            .navigationTitle("Recipes")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Label(title: { Text("Recipes") }, icon: { Image("waterbottle-skip", bundle: .module) })
                        .foregroundColor(.secondary)
                }
            }
        }
#if !SKIP
        .scrollDismissesKeyboard(.immediately)
        .onTapGesture(count: keyboardIsFocused ? 1 : .max, perform: {
            // if keyboard shown use single tap to close it, otherwise set .max to not interfere with other swiftui elements
            keyboardIsFocused = false
        })
#endif
        // TODO: Move the .onChange back when step-ui supports modifiers in line
        .onChange(of: appState.unitVolumeString) {
            appState.unitVolume = Double(appState.unitVolumeString) ?? 0.0
            updateBrewTypeValues()
            updateDescription()
            updateUnits()
        }
        .onChange(of: appState.water) {
            updateBrewTypeValues()
            updateDescription()
            updateUnits()
        }
        .onChange(of: appState.brewType) {
            updateBrewTypeValues()
            updateDescription()
            updateUnits()
        }
        .onChange(of: appState.unit) {
            updateBrewTypeValues()
            updateDescription()
            updateUnits()
        }
    }
}

func updateBrewTypeValues() {
    mainAppState.brewTypeGlacialBuffer = mainAppState.brewType.selectedBrewType.glacial_buffer_grams
    mainAppState.brewTypeGlacialExtrationBooster = mainAppState.brewType.selectedBrewType.glacial_extraction_booster_grams
    mainAppState.brewTypeGlacialHardness = mainAppState.brewType.selectedBrewType.glacial_hardness_grams
    mainAppState.brewTypeSpringBuffer = mainAppState.brewType.selectedBrewType.spring_buffer_grams
    mainAppState.brewTypeSpringExtrationBooster = mainAppState.brewType.selectedBrewType.spring_extraction_booster_grams
    mainAppState.brewTypeSpringHardness = mainAppState.brewType.selectedBrewType.spring_hardness_grams
}

func updateDescription() {
    mainAppState.waterDescription = mainAppState.water.selectedWater.description
}

func updateUnits() {
    mainAppState.unitText = mainAppState.unit.selectedUnit.iOSText
    mainAppState.unitVolume = mainAppState.unit.selectedUnit.initialVolume
    mainAppState.unitVolumeString = String(Int(mainAppState.unit.selectedUnit.initialVolume))
}

//#Preview {
//    RecipesTab()
//        .environmentObject(mainAppState)
//}
