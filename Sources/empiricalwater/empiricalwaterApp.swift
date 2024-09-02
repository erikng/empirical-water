//
//  empiricalwaterApp.swift
//  empirical water
//
//  Created by Erik Gomez on 08/23/24.
//

import Foundation
import OSLog
import SwiftUI

let logger: Logger = Logger(subsystem: "com.empiricalwater.app", category: "empiricalwater")
/// The Android SDK number we are running against, or `nil` if not running on Android
let androidSDK = ProcessInfo.processInfo.environment["android.os.Build.VERSION.SDK_INT"].flatMap({ Int($0) })

var mainAppState = AppState()
class AppState: ObservableObject {
    @Published var water: Waters = .glacial
    @Published var waterDescription: String = Glacial.description
    @Published var brewType: BrewTypes = .light_roast
    @Published var brewTypeAquiferBuffer: Double = lightRoast.aquifer_buffer_grams
    @Published var brewTypeAquiferExtractionBooster: Double = lightRoast.aquifer_extraction_booster_grams
    @Published var brewTypeAquiferHardness: Double = lightRoast.aquifer_hardness_grams
    @Published var brewTypeGlacialBuffer: Double = lightRoast.glacial_buffer_grams
    @Published var brewTypeGlacialExtractionBooster: Double = lightRoast.glacial_extraction_booster_grams
    @Published var brewTypeGlacialHardness: Double = lightRoast.glacial_hardness_grams
    @Published var brewTypeSpringBuffer: Double = lightRoast.spring_hardness_grams
    @Published var brewTypeSpringExtractionBooster: Double = lightRoast.spring_extraction_booster_grams
    @Published var brewTypeSpringHardness: Double = lightRoast.spring_hardness_grams
    @Published var brewTypeNote: String = lightRoast.note
    @Published var unit: Units = .liter
    @Published var unitText = ""
    @Published var unitVolume = 1.0
    @Published var unitVolumeString = "1.0"
}

#if !SKIP
public protocol empiricalwaterApp : App {
}

public extension empiricalwaterApp {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
#endif

public struct RootView : View {
    @StateObject private var appState: AppState = mainAppState
    
    public init() {
    }
    
    public var body: some View {
        ContentView()
            .environmentObject(appState)
            .task {
                logger.log("Running on \(androidSDK != nil ? "Android" : "Darwin")!")
            }
    }
}

public struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    public init() {
    }
    
    public var body: some View {
        RecipeView()
        .onAppear {
            updateBrewTypeValues()
            updateDescription()
        }
        .onChange(of: appState.unitVolumeString) {
            appState.unitVolume = Double(appState.unitVolumeString) ?? 0.0
            updateBrewTypeValues()
            updateDescription()
        }
        .onChange(of: appState.water) {
            updateBrewTypeValues()
            updateDescription()
        }
        .onChange(of: appState.brewType) {
            updateBrewTypeValues()
            updateDescription()
        }
        .onChange(of: appState.unit) {
            updateBrewTypeValues()
            updateDescription()
        }
    }
}

func updateBrewTypeValues() {
    mainAppState.brewTypeAquiferBuffer = mainAppState.brewType.selectedBrewType.aquifer_buffer_grams
    mainAppState.brewTypeAquiferExtractionBooster = mainAppState.brewType.selectedBrewType.aquifer_extraction_booster_grams
    mainAppState.brewTypeAquiferHardness = mainAppState.brewType.selectedBrewType.aquifer_hardness_grams
    mainAppState.brewTypeGlacialBuffer = mainAppState.brewType.selectedBrewType.glacial_buffer_grams
    mainAppState.brewTypeGlacialExtractionBooster = mainAppState.brewType.selectedBrewType.glacial_extraction_booster_grams
    mainAppState.brewTypeGlacialHardness = mainAppState.brewType.selectedBrewType.glacial_hardness_grams
    mainAppState.brewTypeSpringBuffer = mainAppState.brewType.selectedBrewType.spring_buffer_grams
    mainAppState.brewTypeSpringExtractionBooster = mainAppState.brewType.selectedBrewType.spring_extraction_booster_grams
    mainAppState.brewTypeSpringHardness = mainAppState.brewType.selectedBrewType.spring_hardness_grams
}

func updateDescription() {
    mainAppState.waterDescription = mainAppState.water.selectedWater.description
}
