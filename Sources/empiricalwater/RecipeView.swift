//
//  RecipeView.swift
//  empirical water
//
//  Created by Erik Gomez on 08/23/24.
//

import Foundation
import SwiftUI

struct RecipeView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("useVolumetricMeasurementHardness") var useVolumetricMeasurementHardness: Bool = false
    @AppStorage("useVolumetricMeasurementBuffer") var useVolumetricMeasurementBuffer: Bool = false
    @AppStorage("useVolumetricMeasurementExtractionBooster") var useVolumetricMeasurementExtractionBooster: Bool = false
    @AppStorage("useVolumetricMeasurementZeroTDSWater") var useVolumetricMeasurementZeroTDSWater: Bool = false
    @AppStorage("lastVersionLaunched") var lastVersionLaunched: String = "0.0"
    @State var options = [
        Option(title: "hardness"),
        Option(title: "buffer"),
        Option(title: "extraction booster"),
        Option(title: "zero TDS water")
    ]

    var body: some View {
        List {
            Section {
                Picker("Water", selection: $appState.water) {
                    ForEach(Waters.allCases) { water in
                        Text(water.selectedWater.name)
                            .tag(water)
                    }
                }
                
                Picker("Brew", selection: $appState.brewType) {
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
                
                #if !SKIP
                DisclosureGroup("Optional Features", isExpanded: $appState.isOptionsExpanded) {
                    VStack(spacing: 10) {
                        Text("Volumetric - Convert from grams (g) to millileters (mL)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        OptionRow(value: $useVolumetricMeasurementHardness, option: options[0])
                        OptionRow(value: $useVolumetricMeasurementBuffer, option: options[1])
                        OptionRow(value: $useVolumetricMeasurementExtractionBooster, option: options[2])
                        OptionRow(value: $useVolumetricMeasurementZeroTDSWater, option: options[3])
                        
                    }
                    .foregroundColor(.primary)
                    .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 16))
                }
                .foregroundColor(.secondary)
                .accentColor(appState.isOptionsExpanded ? .primary : .secondary)
                .onAppear {
                    if appVersion.compare(lastVersionLaunched, options: .numeric) == .orderedDescending {
                        appState.isOptionsExpanded = true
                        lastVersionLaunched = appVersion
                    }
                }
                #endif
            }

            Section {
                if !appState.water.selectedWater.note.isEmpty {
                    Text(LocalizedStringKey(appState.water.selectedWater.note))
                        .font(.callout)
                }
                
                ForEach(["hardness", "buffer", "extraction booster"], id: \.self) { component in
                    let volumetricValue = {
                        switch component {
                            case "hardness": return useVolumetricMeasurementHardness
                            case "buffer": return useVolumetricMeasurementBuffer
                            case "extraction booster": return useVolumetricMeasurementExtractionBooster
                            default: return false
                        }
                    }()
                    let value = calculateBrewTypeValues(for: component, volumetric: volumetricValue)
                    HStack {
                        Text("\(mainAppState.water.selectedWater.name) \(component)")
                            .font(.callout)
                        Spacer()
                        Text("\(value) \(volumetricValue ? "mL" : "grams")")
                            .font(.callout)
                            .bold()
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color(red: 21.0 / 255.0, green: 67.0 / 255.0, blue: 109.0 / 255.0))
                }
                
                HStack {
                    Text("zero TDS water")
                        .font(.callout)
                    Spacer()
                    let zeroTDSWater = calculateZeroTDSWater()
                    Text("\(zeroTDSWater) \(useVolumetricMeasurementZeroTDSWater ? "mL" : "grams")")
                        .font(.callout)
                        .bold()
                }
                .foregroundColor(.white)
                .listRowBackground(Color.gray)
                
                if !mainAppState.water.selectedWater.description.isEmpty {
                    HStack {
                        Text(LocalizedStringKey(mainAppState.water.selectedWater.description))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text(LocalizedStringKey(mainAppState.brewType.selectedBrewType.note))
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

                Text("Thanks to [Erik Gomez](https://github.com/erikng), the author of [Blossom Rain](https://github.com/erikng/Blossom-Rain), which this code is based on for our application.")
                .foregroundColor(.secondary)
                .font(.caption)
            }
        }
    }
}

struct OptionRow: View {
    // Accept a binding
    @Binding var value: Bool
    let option: Option

    var body: some View {
        Toggle(isOn: $value) {
            Text(option.title)
        }
    }
}
