import Foundation

enum Units: String, CaseIterable, Identifiable, Codable, Sendable {
    case milliliter, liter, gallon
    var id: Self { self }

    var name: String {
        switch self {
        case .milliliter: "Milliliter"
        case .liter: "Liter"
        case .gallon: "US Gallon"
        }
    }

    var symbol: String {
        switch self {
        case .milliliter: "mL"
        case .liter: "L"
        case .gallon: "US gal"
        }
    }

    var initialVolume: Double { self == .milliliter ? 100 : 1 }

    var range: ClosedRange<Double> {
        switch self {
        case .milliliter: 100...1000
        case .liter: 1...20
        case .gallon: 1...5
        }
    }

    var step: Double {
        switch self {
        case .milliliter: 5
        case .liter: 0.25
        case .gallon: 0.5
        }
    }

    func milliliters(for volume: Double) -> Double {
        switch self {
        case .milliliter: volume
        case .liter: volume * 1000
        // Match the empirical water calculator's US gallon constant.
        case .gallon: volume * 3785.41
        }
    }
}
