import Foundation
import SharedModels
import BetaSettingsFeature

public protocol URLSessionProtocol: Sendable {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

enum SimulationError: Error, LocalizedError {
    case missingBundledItems

    var errorDescription: String? {
        switch self {
        case .missingBundledItems:
            return "Simulated data not available."
        }
    }
}

public actor DataService {
    private let apiURL: URL = {
        // swiftlint:disable:next force_unwrapping
        return URL(string: "https://mocki.io/v1/6c823976-465e-401e-ae8d-d657d278e98e")!
    }()
    private let persistenceManager: PersistenceManaging
    private nonisolated let urlSession: URLSessionProtocol
    private var isUsingCachedDataFlag = false
    private let useSimulation: Bool

    public init(
        persistenceManager: PersistenceManaging,
        urlSession: URLSessionProtocol = URLSession.shared,
        useSimulation: Bool = false
    ) {
        self.persistenceManager = persistenceManager
        self.urlSession = urlSession
        self.useSimulation = useSimulation
    }

    public var isUsingCachedData: Bool {
        isUsingCachedDataFlag
    }

    public func fetchData() async throws -> QItem {
        // Only check simulation if the flag is enabled
        if useSimulation, let simulationResult = try handleSimulationIfNeeded() {
            return simulationResult
        }

        // Normal flow continues if simulation is disabled or not active
        isUsingCachedDataFlag = false

        do {
            let (data, _) = try await urlSession.data(from: apiURL)
            let items = try JSONDecoder().decode(QItem.self, from: data)

            await persistenceManager.saveItems(items)
            return items
        } catch {
            // Try to load cached data
            if let cachedItems = await persistenceManager.loadItems() {
                isUsingCachedDataFlag = true
                return cachedItems
            }

            throw error
        }
    }

    private func handleSimulationIfNeeded() throws -> QItem? {
        switch BetaSettings.shared.loadSimulation {
        case .loadWithError:
            isUsingCachedDataFlag = false
            throw URLError(.notConnectedToInternet)

        case .loadCached:
            guard let bundledItems = loadBundledItems() else {
                throw SimulationError.missingBundledItems
            }
            isUsingCachedDataFlag = true
            return bundledItems

        case .loadNormal:
            guard let bundledItems = loadBundledItems() else {
                throw SimulationError.missingBundledItems
            }
            isUsingCachedDataFlag = false
            return bundledItems
        }
    }

    private func loadBundledItems() -> QItem? {
        guard let url = Bundle.module.url(forResource: "Form", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let item = try? JSONDecoder().decode(QItem.self, from: data) else {
            return nil
        }
        return item
    }
}
