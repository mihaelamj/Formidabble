import Foundation

public final class BetaSettings: @unchecked Sendable {
    public static let shared = BetaSettings()
    private init() {}

    private let defaults = UserDefaults.standard
    private let loadSimulationKey = "loadSimulation"

    public var loadSimulation: LoadSimulation {
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
