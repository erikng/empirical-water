//
//  Structs.swift
//  empirical water
//
//  Created by Erik Gomez on 08/23/24.
//

import Foundation
import SwiftUI

struct Option: Identifiable {
    var title: String
    let id = UUID()
}

struct UnitOfMeasurement: Codable, Hashable, Identifiable {
    var id: UUID
    var name: String
}

enum Units: String, CaseIterable, Identifiable {
    case milliliter, liter, gallon
    var id: String { self.rawValue }
}

extension Units {
    var selectedUnit: UnitOfMeasurement {
        switch self {
        case .milliliter: return UnitOfMeasurement(
            id: UUID(),
            name: "Milliliter"
        )
        case .liter: return UnitOfMeasurement(
            id: UUID(),
            name: "Liter"
        )
        case .gallon: return UnitOfMeasurement(
            id: UUID(),
            name: "Gallon"
        )
        }
    }

    var unitColor: Color {
        switch self {
        case .milliliter:
            return Color(red: 21.0 / 255.0, green: 67.0 / 255.0, blue: 109.0 / 255.0)
        case .liter:
            return Color(red: 21.0 / 255.0, green: 67.0 / 255.0, blue: 109.0 / 255.0)
        case .gallon:
            return .secondary
        }
    }
}

struct Water: Codable, Hashable, Identifiable {
    var id: UUID
    var name: String
    var note: String = ""
    var description: String
}

enum Waters: String, CaseIterable, Identifiable {
    case aquifer, glacial, spring // TODO: Add here for another water type
    
    var id: String { self.rawValue }

    var selectedWater: Water {
        switch self {
        case .aquifer: return Aquifer
        case .glacial: return Glacial
        case .spring: return Spring
        // TODO: Add here for another water type
        }
    }
}

struct WaterSource {
    var bufferGrams: Double
    var bufferMLs: Double
    var extractionBoosterGrams: Double
    var extractionBoosterMLs: Double
    var hardnessGrams: Double
    var hardnessMLs: Double
}

struct BrewType: Identifiable {
    var id: UUID
    var name: String
    var note: String = "**Note:** For best accuracy, rely primarily on the 0.50 mL fill line for measuring buffer. For higher intensity and acidity, use less buffer. For lower intensity and acidity, use more buffer."
    var aquifer: WaterSource
    var glacial: WaterSource
    var spring: WaterSource
    // TODO: Add here for another water type
}

enum BrewTypes: String, CaseIterable, Identifiable {
    case light_roast, medium_roast, dark_roast, espresso, tea
    
    var id: String { self.rawValue }
    
    var selectedBrewType: BrewType {
        switch self {
        case .light_roast: return lightRoast
        case .medium_roast: return mediumRoast
        case .dark_roast: return darkRoast
        case .espresso: return Espresso
        case .tea: return Tea
        }
    }
    
    var brewColor: Color {
        switch self {
        case .light_roast:
            return Color(red: 184.0 / 255.0, green: 115.0 / 255.0, blue: 51.0 / 255.0) // Copper
        case .medium_roast:
            return Color(red: 150.0 / 255.0, green: 75.0 / 255.0, blue: 0.0 / 255.0) // Brown
        case .dark_roast:
            return Color(red: 101.0 / 255.0, green: 67.0 / 255.0, blue: 33.0 / 255.0) // Dark Brown
        case .espresso:
            return Color(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0) // Black
        case .tea:
            return Color(red: 85.0 / 255.0, green: 107.0 / 255.0, blue: 47.0 / 255.0) // Dark Olive Green
        }
    }
}

// Configure the water types
let Aquifer = Water(
    id: UUID(),
    name: "aquifer",
    note: "**Coming Soon!**", // TODO: Remove this when ready
    description: "**[aquifer](https://empiricalwater.com/products/empirical-water-aquifer)** is a comprehensive mineral profile for brewing any coffee or tea, inspired by aquifer water."
)

let Glacial = Water(
    id: UUID(),
    name: "glacial",
    description: "Inspired by natural mineral water from glaciers, our **[glacial](https://empiricalwater.com/products/empirical-water-glacial)** profile is harmonious and lively, emphasizing clarity and complexity in coffee & tea. We reverse-engineered glacial mineral water by painstakingly emulating the natural limestone dissolution process, for record-low levels of chloride and sulfate impurities in our water."
)

let Spring = Water(
    id: UUID(),
    name: "spring",
    description: "Inspired by natural mineral water from springs, our **[spring](https://empiricalwater.com/products/empirical-water-spring)** profile is thick, concentrated and resonant, emphasizing body and richness in coffee & tea. We reverse-engineered glacial mineral water by painstakingly emulating the natural limestone dissolution process, for record low levels of chloride and sulfate impurities in our water."
)

// TODO: Add here for another water type

// Configure the brew types
let lightRoast = BrewType(
    id: UUID(),
    name: "Light Roast",
    // TODO: Put actual calculations
    aquifer: WaterSource(
        bufferGrams: 0.0,
        bufferMLs: 0.0,
        extractionBoosterGrams: 0.0,
        extractionBoosterMLs: 0.0,
        hardnessGrams: 0.0,
        hardnessMLs: 0.0
    ),
    glacial: WaterSource(
        bufferGrams: 0.59,
        bufferMLs: 0.50,
        extractionBoosterGrams: 0.59,
        extractionBoosterMLs: 0.50,
        hardnessGrams: 50.0,
        hardnessMLs: 50.0
    ),
    spring: WaterSource(
        bufferGrams: 1.18,
        bufferMLs: 1.0,
        extractionBoosterGrams: 1.18,
        extractionBoosterMLs: 1.0,
        hardnessGrams: 100.0,
        hardnessMLs: 100.0
    )
    // TODO: Add here for another water type
)

let mediumRoast = BrewType(
    id: UUID(),
    name: "Medium Roast",
    // TODO: Put actual calculations
    aquifer: WaterSource(
        bufferGrams: 0.0,
        bufferMLs: 0.0,
        extractionBoosterGrams: 0.0,
        extractionBoosterMLs: 0.0,
        hardnessGrams: 0.0,
        hardnessMLs: 0.0
    ),
    glacial: WaterSource(
        bufferGrams: 1.18,
        bufferMLs: 1.0,
        extractionBoosterGrams: 0.59,
        extractionBoosterMLs: 0.50,
        hardnessGrams: 50.0,
        hardnessMLs: 50.0
    ),
    spring: WaterSource(
        bufferGrams: 2.36,
        bufferMLs: 2.0,
        extractionBoosterGrams: 1.18,
        extractionBoosterMLs: 1.0,
        hardnessGrams: 100.0,
        hardnessMLs: 100.0
    )
    // TODO: Add here for another water type
)

let darkRoast = BrewType(
    id: UUID(),
    name: "Dark Roast",
    // TODO: Put actual calculations
    aquifer: WaterSource(
        bufferGrams: 0.0,
        bufferMLs: 0.0,
        extractionBoosterGrams: 0.0,
        extractionBoosterMLs: 0.0,
        hardnessGrams: 0.0,
        hardnessMLs: 0.0
    ),
    glacial: WaterSource(
        bufferGrams: 1.77,
        bufferMLs: 1.50,
        extractionBoosterGrams: 0.59,
        extractionBoosterMLs: 0.50,
        hardnessGrams: 50.0,
        hardnessMLs: 50.0
    ),
    spring: WaterSource(
        bufferGrams: 3.54,
        bufferMLs: 3.0,
        extractionBoosterGrams: 1.18,
        extractionBoosterMLs: 1.0,
        hardnessGrams: 100.0,
        hardnessMLs: 100.0
    )
    // TODO: Add here for another water type
)

let Espresso = BrewType(
    id: UUID(),
    name: "Espresso",
    // TODO: Put actual calculations
    aquifer: WaterSource(
        bufferGrams: 0.0,
        bufferMLs: 0.0,
        extractionBoosterGrams: 0.0,
        extractionBoosterMLs: 0.0,
        hardnessGrams: 0.0,
        hardnessMLs: 0.0
    ),
    glacial: WaterSource(
        bufferGrams: 1.77,
        bufferMLs: 1.50,
        extractionBoosterGrams: 0.59,
        extractionBoosterMLs: 0.50,
        hardnessGrams: 50.0,
        hardnessMLs: 50.0
    ),
    // Spring does not support espresso
    spring: WaterSource(
        bufferGrams: 0.0,
        bufferMLs: 0.0,
        extractionBoosterGrams: 0.0,
        extractionBoosterMLs: 0.0,
        hardnessGrams: 0.0,
        hardnessMLs: 0.0
    )
    // TODO: Add here for another water type
)

let Tea = BrewType(
    id: UUID(),
    name: "Tea",
    // TODO: Put actual calculations
    aquifer: WaterSource(
        bufferGrams: 0.0,
        bufferMLs: 0.0,
        extractionBoosterGrams: 0.0,
        extractionBoosterMLs: 0.0,
        hardnessGrams: 0.0,
        hardnessMLs: 0.0
    ),
    glacial: WaterSource(
        bufferGrams: 0.59,
        bufferMLs: 0.50,
        extractionBoosterGrams: 0.59,
        extractionBoosterMLs: 0.50,
        hardnessGrams: 50.0,
        hardnessMLs: 50.0
    ),
    spring: WaterSource(
        bufferGrams: 1.18,
        bufferMLs: 1.0,
        extractionBoosterGrams: 1.18,
        extractionBoosterMLs: 1.0,
        hardnessGrams: 100.0,
        hardnessMLs: 100.0
    )
    // TODO: Add here for another water type
)

func calculateBrewTypeValues(for component: String, volumetric: Bool) -> String {
    var value: Double = 0.0
    let volumeCalculation = mainAppState.unit == .milliliter ? mainAppState.unitVolume / 1000 : mainAppState.unit == .liter ? mainAppState.unitVolume : mainAppState.unitVolume * 3.785
    
    let waterSource = {
        switch mainAppState.water.selectedWater.name {
        case "aquifer": return mainAppState.brewType.selectedBrewType.aquifer
        case "glacial": return mainAppState.brewType.selectedBrewType.glacial
        case "spring": return mainAppState.brewType.selectedBrewType.spring
        // TODO: Add here for another water type
        default: return WaterSource(bufferGrams: 0, bufferMLs: 0, extractionBoosterGrams: 0, extractionBoosterMLs: 0, hardnessGrams: 0, hardnessMLs: 0)
        }
    }()
    
    switch component {
    case "hardness": value = volumetric ? waterSource.hardnessMLs * volumeCalculation : waterSource.hardnessGrams * volumeCalculation
    case "buffer": value = volumetric ? waterSource.bufferMLs * volumeCalculation : waterSource.bufferGrams * volumeCalculation
    case "extraction booster": value = volumetric ? waterSource.extractionBoosterMLs * volumeCalculation : waterSource.extractionBoosterGrams * volumeCalculation
    default: break
    }
    
    return String(format: "%.2f", value)
}

func calculateZeroTDSWater() -> String {
    let volumeCalculation = mainAppState.unit == .milliliter ? mainAppState.unitVolume / 1000 : mainAppState.unit == .liter ? mainAppState.unitVolume : mainAppState.unitVolume * 3.785
    var value: Double = 0.0
    
    switch mainAppState.water {
    case .aquifer:
        return "0" // TODO: Remove when ready
    case .glacial:
        value = 950 * volumeCalculation
    case .spring:
        if mainAppState.brewType.selectedBrewType.name != "Espresso" {
            value = 900 * volumeCalculation
        } else {
            return "0"
        }
    // TODO: Add here for another water type
    default:
        return ""
    }
    
    return String(format: "%.2f", value)
}
