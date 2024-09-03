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

class AppState: ObservableObject {
    @Published var water: Waters = .glacial
    @Published var brewType: BrewTypes = .light_roast
    @Published var unit: Units = .liter
    @Published var unitVolume = 1.0
}
var mainAppState = AppState()

public struct RootView : View {
    @StateObject private var appState: AppState = mainAppState
    
    public init() {
    }
    
    public var body: some View {
        RecipeView()
            .environmentObject(appState)
            .task {
                logger.log("Running on \(androidSDK != nil ? "Android" : "Darwin")!")
            }
    }
}
