//
//  SettingsTab.swift
//  empirical water
//
//  Created by Erik Gomez on 08/23/24.
//

import SwiftUI

struct SettingsTab: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("disableIdleTimer") var disableIdleTimer: Bool = false
    @AppStorage("useManualVolumeInput") var useManualVolumeInput: Bool = false
    @AppStorage("volumeInputStepper") var volumeInputStepper: Double = 25.0
    var volumeInputSteppers = [1.0, 5.0, 10.0, 20.0, 25.0]
    
    var body: some View {
        NavigationStack {
            Form {
                // Volume Input
                Section {
                    if !useManualVolumeInput {
                        VStack(alignment: .leading) {
                            Text("Volume Input Steps (mL)")
                            Text("The amount of steps the **milliliter** slider will increase or decrease by.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Picker("Appearance", selection: $volumeInputStepper) {
                                ForEach(volumeInputSteppers, id: \.self) {
                                    Text(String(Int($0)))
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Toggle(isOn: $useManualVolumeInput) {
                            VStack(alignment: .leading) {
                                Text("Manual Volume Input")
                                Text("If you would prefer to input the volume manually, select this option.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
#if !targetEnvironment(macCatalyst)
                    VStack(alignment: .leading) {
                        Toggle(isOn: $disableIdleTimer) {
                            VStack(alignment: .leading) {
                                Text("Disable Screen Sleep")
                                Text("Prevent the device from going to sleep while the application running.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
#endif
                } header: {
                    Text("User Interface")
                } footer: {}
                
                // empirical water
                Section {
                    HStack(spacing: 0) {
                        Link("empirical", destination: URL(string: "https://empiricalwater.com")!)
                            .bold()
                            .foregroundColor(Color(red: 21.0/255.0, green: 67.0/255.0, blue: 109.0/255.0))
                        
                        Text(" ")
                            .foregroundColor(.secondary)
                        
                        Link("water", destination: URL(string: "https://empiricalwater.com")!)
                            .bold()
                            .foregroundColor(Color(red: 0.0/255.0, green: 199.0/255.0, blue: 255.0/255.0))
                        
                        Text(" ")
                            .foregroundColor(.secondary)
                        
                        Text("is founded by [Arby Avanesian](https://www.instagram.com/arbyavanesian)")
                            .foregroundColor(.secondary)
                    }
                    .font(.footnote)
                } header: {
                    Text("Acknowledgements")
                } footer: {}

                // Original Authorship
                Section {
                    Group {
                        Text("[Blossom Rain](https://github.com/erikng/Blossom-Rain) - the original application this code is based upon.")
                        Text("[Erik Gomez](https://github.com/erikng) - the author of Blossom Rain and v1.0 of our application.")
                    }
                    .foregroundColor(.secondary)
                    .font(.footnote)
                } header: {
                    Text("Further thanks")
                } footer: {}
            }
            .navigationTitle("Settings")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Label(title: { Text("Settings") }, icon: { Image("slider.horizontal.3-skip", bundle: .module) })
                        .foregroundColor(.secondary)
                }
            }
        }
        // TODO: Move the .onChange back when step-ui supports modifiers in line
        .onChange(of: disableIdleTimer) {
            updateScreenIdleTimer(disableIdleTimer: disableIdleTimer)
        }
        .onChange(of: useManualVolumeInput) {
            updateUnits()
        }
    }
}

//#Preview {
//    SettingsTab()
//        .environmentObject(mainAppState)
//}
