import Observation

/// A brewing session owned by one SwiftUI window; no mutable global state.
@MainActor
@Observable
final class AppState {
    var brewType: BrewTypes = .light_roast
    var isOptionsExpanded = false
    var unit: Units = .liter {
        didSet {
            if unit != oldValue { unitVolume = unit.initialVolume }
        }
    }
    var unitVolume = 1.0
    var boosterPerLiter = 0.0
    var water: Waters = .glacial {
        didSet {
            if water.profile.recipe(for: brewType) == nil { brewType = water.defaultBrew }
        }
    }
}
