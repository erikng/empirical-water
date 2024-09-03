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
            }
            
            Section {
                if !appState.water.selectedWater.note.isEmpty {
                    Text(LocalizedStringKey(appState.water.selectedWater.note))
                        .font(.callout)
                }
                
                ForEach(["hardness", "buffer", "extraction booster"], id: \.self) { component in
                    let value = calculateBrewTypeValues(for: component)
                    HStack {
                        Text("\(mainAppState.water.selectedWater.name) \(component)")
                            .font(.callout)
                        Spacer()
                        Text("\(value) \(component == "hardness" ? "mL" : "grams")")
                            .font(.callout)
                            .bold()
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color(red: 21.0 / 255.0, green: 67.0 / 255.0, blue: 109.0 / 255.0))
                }
                
                HStack {
                    Text("Zero TDS Water")
                        .font(.callout)
                    Spacer()
                    let zeroTDSWater = calculateZeroTDSWater()
                    Text("\(zeroTDSWater) mL")
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
