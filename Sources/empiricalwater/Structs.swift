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
    var description: String
}

enum Waters: String, CaseIterable, Identifiable {
    case aquifer, glacial, spring
    
    var id: String { self.rawValue }

    var selectedWater: Water {
        switch self {
        case .aquifer: return Aquifer
        case .glacial: return Glacial
        case .spring: return Spring
        }
    }
}

struct BrewType: Codable, Hashable, Identifiable {
    var id: UUID
    var name: String
    var note: String
    var aquifer_buffer_grams: Double
    var aquifer_extraction_booster_grams: Double
    var aquifer_hardness_grams: Double
    var glacial_buffer_grams: Double
    var glacial_extraction_booster_grams: Double
    var glacial_hardness_grams: Double
    var spring_buffer_grams: Double
    var spring_extraction_booster_grams: Double
    var spring_hardness_grams: Double
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

// Configure the brew types
let lightRoast = BrewType(
    id: UUID(),
    name: "Light Roast",
    note: "Note: For best accuracy, rely primarily on the 0.50 mL fill line for measuring buffer. For higher intensity and acidity, use less buffer. For lower intensity and acidity, use more buffer.",
    aquifer_buffer_grams: 0.0,
    aquifer_extraction_booster_grams: 0.0,
    aquifer_hardness_grams: 0.0,
    glacial_buffer_grams: 0.59,
    glacial_extraction_booster_grams: 0.59,
    glacial_hardness_grams: 50.0,
    spring_buffer_grams: 1.18,
    spring_extraction_booster_grams: 1.18,
    spring_hardness_grams: 100.0
)

let mediumRoast = BrewType(
    id: UUID(),
    name: "Medium Roast",
    note: "Note: For best accuracy, rely primarily on the 0.50 mL fill line for measuring buffer. For higher intensity and acidity, use less buffer. For lower intensity and acidity, use more buffer.",
    aquifer_buffer_grams: 0.0,
    aquifer_extraction_booster_grams: 0.0,
    aquifer_hardness_grams: 0.0,
    glacial_buffer_grams: 1.18,
    glacial_extraction_booster_grams: 0.59,
    glacial_hardness_grams: 50.0,
    spring_buffer_grams: 2.36,
    spring_extraction_booster_grams: 1.18,
    spring_hardness_grams: 100.0
)

let darkRoast = BrewType(
    id: UUID(),
    name: "Dark Roast",
    note: "Note: For best accuracy, rely primarily on the 0.50 mL fill line for measuring buffer. For higher intensity and acidity, use less buffer. For lower intensity and acidity, use more buffer.",
    aquifer_buffer_grams: 0.0,
    aquifer_extraction_booster_grams: 0.0,
    aquifer_hardness_grams: 0.0,
    glacial_buffer_grams: 1.77,
    glacial_extraction_booster_grams: 0.59,
    glacial_hardness_grams: 50.0,
    spring_buffer_grams: 3.54,
    spring_extraction_booster_grams: 1.18,
    spring_hardness_grams: 100.0
)

let Espresso = BrewType(
    id: UUID(),
    name: "Espresso",
    note: "Note: For best accuracy, rely primarily on the 0.50 mL fill line for measuring buffer. For higher intensity and acidity, use less buffer. For lower intensity and acidity, use more buffer.",
    aquifer_buffer_grams: 0.0,
    aquifer_extraction_booster_grams: 0.0,
    aquifer_hardness_grams: 0.0,
    glacial_buffer_grams: 1.77,
    glacial_extraction_booster_grams: 0.59,
    glacial_hardness_grams: 50.0,
    spring_buffer_grams: 0.0,
    spring_extraction_booster_grams: 0.0,
    spring_hardness_grams: 0.0
)

let Tea = BrewType(
    id: UUID(),
    name: "Tea",
    note: "Note: For best accuracy, rely primarily on the 0.50 mL fill line for measuring buffer. For higher intensity and acidity, use less buffer. For lower intensity and acidity, use more buffer.",
    aquifer_buffer_grams: 0.0,
    aquifer_extraction_booster_grams: 0.0,
    aquifer_hardness_grams: 0.0,
    glacial_buffer_grams: 0.59,
    glacial_extraction_booster_grams: 0.59,
    glacial_hardness_grams: 50.0,
    spring_buffer_grams: 1.18,
    spring_extraction_booster_grams: 1.18,
    spring_hardness_grams: 100.0
)
