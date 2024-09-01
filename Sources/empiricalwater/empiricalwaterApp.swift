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

class AppState: ObservableObject {
    @Published var numberZeroStringFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.zeroSymbol = ""
        return formatter
    }()
    @Published var water: Waters = .glacial
    @Published var waterDescription: String = Glacial.description
    @Published var brewType: BrewTypes = .light_roast
    @Published var brewTypeGlacialBuffer: Double = lightRoast.glacial_buffer_grams
    @Published var brewTypeGlacialExtrationBooster: Double = lightRoast.glacial_extraction_booster_grams
    @Published var brewTypeGlacialHardness: Double = lightRoast.glacial_hardness_grams
    @Published var brewTypeSpringBuffer: Double = lightRoast.spring_hardness_grams
    @Published var brewTypeSpringExtrationBooster: Double = lightRoast.spring_extraction_booster_grams
    @Published var brewTypeSpringHardness: Double = lightRoast.spring_hardness_grams
    @Published var brewTypeNote: String = lightRoast.note
    @Published var unit: Units = .liter
    @Published var unitText = ""
    @Published var unitVolume = 1.0
    @Published var unitVolumeString = "1.0"
}
var mainAppState = AppState()

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

#if !SKIP
public protocol empiricalwaterApp : App {
}

public extension empiricalwaterApp {
    var body: some Scene {
        WindowGroup {
            RootView()
#if targetEnvironment(macCatalyst)
                .onReceive(NotificationCenter.default.publisher(for: UIScene.willConnectNotification)) { _ in
                    // prevent window in macOS from being resized down
                    UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
                        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 800, height: 1000)
                        windowScene.sizeRestrictions?.maximumSize = CGSize(width: 800, height: 1000)
                        windowScene.sizeRestrictions?.allowsFullScreen = false
                    }
                }
#endif
        }
    }
}
#endif

