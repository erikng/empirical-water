//
//  Recipes.swift
//  empirical water
//
//  Created by Erik Gomez on 08/23/24.
//

import Foundation

// Define the Water struct
struct Water: Codable, Hashable, Identifiable {
    var id: UUID
    var name: String
    var description: String
}

// Enum for Waters that conforms to Identifiable using String as the ID
enum Waters: String, CaseIterable, Identifiable {
    case glacial, spring
    
    // Use the rawValue of the enum as the id
    var id: String { self.rawValue }
    
    // Return the associated Water for each case
    var selectedWater: Water {
        switch self {
        case .glacial: return Glacial
        case .spring: return Spring
        }
    }
}

// Configure the water types
let Glacial = Water(
    id: UUID(),
    name: "Glacial",
    description: "Inspired by natural mineral water from glaciers, our **GLACIAL** profile is harmonious and lively, emphasizing clarity and complexity in coffee & tea. We reverse-engineered glacial mineral water by painstakingly emulating the natural limestone dissolution process, for record-low levels of chloride and sulfate impurities in our water."
)

let Spring = Water(
    id: UUID(),
    name: "Spring",
    description: "Inspired by natural mineral water from springs, our **SPRING** profile is thick, concentrated and resonant, emphasizing body and richness in coffee & tea. We reverse-engineered glacial mineral water by painstakingly emulating the natural limestone dissolution process, for record low levels of chloride and sulfate impurities in our water."
)

// Define the BrewType struct
struct BrewType: Codable, Hashable, Identifiable {
    var id: UUID
    var name: String
    var note: String
    var glacial_buffer_grams: Double
    var glacial_extraction_booster_grams: Double
    var glacial_hardness_grams: Double
    var spring_buffer_grams: Double
    var spring_extraction_booster_grams: Double
    var spring_hardness_grams: Double
}

// Enum for BrewTypes that conforms to Identifiable using String as the ID
enum BrewTypes: String, CaseIterable, Identifiable {
    case light_roast, medium_roast, dark_roast, espresso, tea
    
    // Use the rawValue of the enum as the id
    var id: String { self.rawValue }
    
    // Return the associated BrewType for each case
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

// Configure the BrewTypes
let lightRoast = BrewType(
    id: UUID(),
    name: "Light Roast",
    note: "Note: For best accuracy, rely primarily on the 0.50 mL fill line for measuring buffer. For higher intensity and acidity, use less buffer. For lower intensity and acidity, use more buffer.",
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
    glacial_buffer_grams: 0.59,
    glacial_extraction_booster_grams: 0.59,
    glacial_hardness_grams: 50.0,
    spring_buffer_grams: 1.18,
    spring_extraction_booster_grams: 1.18,
    spring_hardness_grams: 100.0
)
