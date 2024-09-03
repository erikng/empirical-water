//
//  Structs.swift
//  empirical water
//
//  Created by Erik Gomez on 08/23/24.
//

import Foundation

struct UnitOfMeasurement: Codable, Hashable, Identifiable {
    var id: UUID
    var name: String
}

enum Units: String, CaseIterable, Identifiable {
    case liter, gallon
    var id: String { self.rawValue }
}

extension Units {
    var selectedUnit: UnitOfMeasurement {
        switch self {
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
    var extractionBoosterGrams: Double
    var hardnessGrams: Double
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
    aquifer: WaterSource(bufferGrams: 0.0, extractionBoosterGrams: 0.0, hardnessGrams: 0.0),
    glacial: WaterSource(bufferGrams: 0.59, extractionBoosterGrams: 0.59, hardnessGrams: 50.0),
    spring: WaterSource(bufferGrams: 1.18, extractionBoosterGrams: 1.18, hardnessGrams: 100.0)
    // TODO: Add here for another water type
)

let mediumRoast = BrewType(
    id: UUID(),
    name: "Medium Roast",
    aquifer: WaterSource(bufferGrams: 0.0, extractionBoosterGrams: 0.0, hardnessGrams: 0.0),
    glacial: WaterSource(bufferGrams: 1.18, extractionBoosterGrams: 0.59, hardnessGrams: 50.0),
    spring: WaterSource(bufferGrams: 2.36, extractionBoosterGrams: 1.18, hardnessGrams: 100.0)
    // TODO: Add here for another water type
)

let darkRoast = BrewType(
    id: UUID(),
    name: "Dark Roast",
    aquifer: WaterSource(bufferGrams: 0.0, extractionBoosterGrams: 0.0, hardnessGrams: 0.0),
    glacial: WaterSource(bufferGrams: 1.77, extractionBoosterGrams: 0.59, hardnessGrams: 50.0),
    spring: WaterSource(bufferGrams: 3.54, extractionBoosterGrams: 1.18, hardnessGrams: 100.0)
    // TODO: Add here for another water type
)

let Espresso = BrewType(
    id: UUID(),
    name: "Espresso",
    aquifer: WaterSource(bufferGrams: 0.0, extractionBoosterGrams: 0.0, hardnessGrams: 0.0),
    glacial: WaterSource(bufferGrams: 1.77, extractionBoosterGrams: 0.59, hardnessGrams: 50.0),
    spring: WaterSource(bufferGrams: 0.0, extractionBoosterGrams: 0.0, hardnessGrams: 0.0)
    // TODO: Add here for another water type
)

let Tea = BrewType(
    id: UUID(),
    name: "Tea",
    aquifer: WaterSource(bufferGrams: 0.0, extractionBoosterGrams: 0.0, hardnessGrams: 0.0),
    glacial: WaterSource(bufferGrams: 0.59, extractionBoosterGrams: 0.59, hardnessGrams: 50.0),
    spring: WaterSource(bufferGrams: 1.18, extractionBoosterGrams: 1.18, hardnessGrams: 100.0)
    // TODO: Add here for another water type
)

func calculateBrewTypeValues(for component: String) -> String {
    var value: Double = 0.0
    let volumeCalculation = mainAppState.unit == .liter ? mainAppState.unitVolume : mainAppState.unitVolume * 3.785
    
    let waterSource = {
        switch mainAppState.water.selectedWater.name {
        case "aquifer": return mainAppState.brewType.selectedBrewType.aquifer
        case "glacial": return mainAppState.brewType.selectedBrewType.glacial
        case "spring": return mainAppState.brewType.selectedBrewType.spring
        // TODO: Add here for another water type
        default: return WaterSource(bufferGrams: 0, extractionBoosterGrams: 0, hardnessGrams: 0)
        }
    }()
    
    switch component {
    case "hardness": value = waterSource.hardnessGrams * volumeCalculation
    case "buffer": value = waterSource.bufferGrams * volumeCalculation
    case "extraction booster": value = waterSource.extractionBoosterGrams * volumeCalculation
    default: break
    }
    
    return String(format: "%.2f", value)
}

func calculateZeroTDSWater() -> String {
    let volumeCalculation = mainAppState.unit == .liter ? mainAppState.unitVolume : mainAppState.unitVolume * 3.785
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
