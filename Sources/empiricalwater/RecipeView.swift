//
//  RecipeView.swift
//  empirical water
//
//  Created by Erik Gomez on 08/23/24.
//

import SwiftUI

struct RecipeView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        List {
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
                
                Picker("Unit", selection: $appState.unit) {
                    ForEach(Units.allCases) { unit in
                        Text(unit.selectedUnit.name)
                            .tag(unit)
                    }
                }
                
                HStack {
                    Slider(
                        value: $appState.unitVolume,
                        in: appState.unit == .liter ? 0.0...20.0 : 0.0...5.0,
                        step: 1.0
                    )
                    Text(String(Int(appState.unitVolume)))
                }
            }
            
            Section {
                if appState.water == .aquifer {
                    Text("Coming Soon!")
                        .font(.callout)
                        .fontWeight(.bold)
                }
                HStack {
                    Text(appState.water == .glacial ? "glacial hardness" : "spring hardness")
                        .font(.callout)
                    Spacer()
                    let hardnessValue: String = {
                        var volumeCalculation: Double
                        if appState.unit == .liter {
                            volumeCalculation = appState.unitVolume
                        } else {
                            volumeCalculation = appState.unitVolume * 3.785
                        }
                        if appState.water == .aquifer {
                            let value = appState.brewTypeAquiferHardness * volumeCalculation
                            return String(format: "%.2f", value)
                        } else if appState.water == .glacial {
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
                        .font(.callout)
                        .bold()
                }
                .foregroundColor(.white)
                .listRowBackground(Color(red: 21.0/255.0, green: 67.0/255.0, blue: 109.0/255.0))
                
                HStack {
                    Text(appState.water == .glacial ? "glacial buffer" : "spring buffer")
                        .font(.callout)
                    Spacer()
                    let bufferValue: String = {
                        var volumeCalculation: Double
                        if appState.unit == .liter {
                            volumeCalculation = appState.unitVolume
                        } else {
                            volumeCalculation = appState.unitVolume * 3.785
                        }
                        if appState.water == .aquifer {
                            let value = appState.brewTypeAquiferBuffer * volumeCalculation
                            return String(format: "%.2f", value)
                        } else if appState.water == .glacial {
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
                        .font(.callout)
                        .bold()
                }
                .foregroundColor(.white)
                .listRowBackground(Color(red: 21.0/255.0, green: 67.0/255.0, blue: 109.0/255.0))
                
                HStack {
                    Text("Optional: extraction booster")
                        .font(.callout)
                    Spacer()
                    let extractionboosterValue: String = {
                        var volumeCalculation: Double
                        if appState.unit == .liter {
                            volumeCalculation = appState.unitVolume
                        } else {
                            volumeCalculation = appState.unitVolume * 3.785
                        }
                        if appState.water == .aquifer {
                            let value = appState.brewTypeAquiferExtractionBooster * volumeCalculation
                            return String(format: "%.2f", value)
                        } else if appState.water == .glacial {
                            let value = appState.brewTypeGlacialExtractionBooster * volumeCalculation
                            return String(format: "%.2f", value)
                        } else if appState.water == .spring {
                            let value = appState.brewTypeSpringExtractionBooster * volumeCalculation
                            return String(format: "%.2f", value)
                        } else {
                            return ""
                        }
                    }()
                    Text("\(extractionboosterValue) grams")
                        .font(.callout)
                        .bold()
                }
                .foregroundColor(.white)
                .listRowBackground(Color(red: 21.0/255.0, green: 67.0/255.0, blue: 109.0/255.0))
                
                HStack {
                    Text("Zero TDS Water")
                        .font(.callout)
                    Spacer()
                    let zeroTDSWater: String = {
                        var volumeCalculation: Double
                        if appState.unit == .liter {
                            volumeCalculation = appState.unitVolume
                        } else {
                            volumeCalculation = appState.unitVolume * 3.785
                        }
                        if appState.water == .aquifer {
                            return "0" // TODO: Remove when ready
                            let value = 950 * volumeCalculation
                            return String(format: "%.2f", value)
                        } else if appState.water == .glacial {
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
                        .font(.callout)
                        .bold()
                }
                .foregroundColor(.white)
                .listRowBackground(Color.gray)
                
                HStack {
                    if !appState.waterDescription.isEmpty {
                        Text(LocalizedStringKey(appState.waterDescription))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("**Note:** For best accuracy, rely primarily on the 0.50 mL fill line for measuring buffer. For higher intensity and acidity, use less buffer. For lower intensity and acidity, use more buffer.")
                        .foregroundColor(.secondary)
                        .font(.caption2)
                }
            }
            
            Section {
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

                Text("Thanks to [Erik Gomez](https://github.com/erikng), the author of [Blossom Rain](https://github.com/erikng/Blossom-Rain), which this code is based on and v1.0 of our application.")
                .foregroundColor(.secondary)
                .font(.caption)
            }
        }
    }
}
