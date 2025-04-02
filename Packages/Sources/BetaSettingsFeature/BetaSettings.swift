import Foundation

final class BetaSettings: @unchecked Sendable {
    static let shared = BetaSettings()
    private init() {}

    private let defaults = UserDefaults.standard
    private let loadSimulationKey = "loadSimulation"

    var loadSimulation: LoadSimulation {
        get {
            if let raw = defaults.string(forKey: loadSimulationKey),
               let value = LoadSimulation(rawValue: raw) {
                return value
            }
            return .loadNormal
        }
        set {
            defaults.setValue(newValue.rawValue, forKey: loadSimulationKey)
        }
    }
}
