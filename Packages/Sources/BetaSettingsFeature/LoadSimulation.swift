import Foundation

public enum LoadSimulation: String, CaseIterable, Codable, Hashable {
    case loadCached
    case loadNormal
    case loadWithError

    public var description: String {
        switch self {
        case .loadCached: return "Load Cached Data"
        case .loadNormal: return "Load Normal Data"
        case .loadWithError: return "Simulate Error"
        }
    }
}
