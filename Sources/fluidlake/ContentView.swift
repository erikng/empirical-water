//
//  ContentView.swift
//  fluid lake
//
//  Created by Erik Gomez on 08/23/24.
//

import SwiftUI

public struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("disableIdleTimer") var disableIdleTimer: Bool = false
    
    public init() {
    }
    
    public var body: some View {
        TabView {
            RecipesTab()
                .tabItem {
                    Label(title: { Text("Recipes") }, icon: { Image("waterbottle-skip", bundle: .module) })
                }
            SettingsTab()
                .tabItem {
                    Label(title: { Text("Settings") }, icon: { Image("slider.horizontal.3-skip", bundle: .module) })
                }
        }
        .onAppear {
            updateBrewTypeValues()
            updateDescription()
            updateScreenIdleTimer(disableIdleTimer: disableIdleTimer)
            updateUnits()
        }
    }
}

func updateScreenIdleTimer(disableIdleTimer: Bool) {
#if !os(macOS)
    if disableIdleTimer {
        UIApplication.shared.isIdleTimerDisabled = true
    } else {
        UIApplication.shared.isIdleTimerDisabled = false
    }
#endif
}

//#Preview {
//    ContentView()
//        .environmentObject(mainAppState)
//}
