import Foundation
import SharedModels

public protocol URLSessionProtocol: Sendable {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

public actor DataService {
    private let apiURL: URL = {
        // swiftlint:disable:next force_unwrapping
        return URL(string: "https://run.mocky.io/v3/1800b96f-c579-49e5-b0b8-49856a36ce39")!
    }()
    private let persistenceManager: PersistenceManaging
    private nonisolated let urlSession: URLSessionProtocol
    
    public init(persistenceManager: PersistenceManaging, urlSession: URLSessionProtocol = URLSession.shared) {
        self.persistenceManager = persistenceManager
        self.urlSession = urlSession
    }

    public func fetchData() async throws -> [QItem] {
        do {
            let (data, _) = try await urlSession.data(from: apiURL)
            let items = try JSONDecoder().decode([QItem].self, from: data)

            await persistenceManager.saveItems(items)
            return items
        } catch {
            // 1. Try to load cached data
            if let cachedItems = await persistenceManager.loadItems() {
                return cachedItems
            }

            // 2. Try to load bundled JSON as a last resort
            if let bundledItems = loadBundledItems() {
                return bundledItems
            }

            throw error
        }
    }

    private func loadBundledItems() -> [QItem]? {
        guard let url = Bundle.module.url(forResource: "Form", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let wrapper = try? JSONDecoder().decode(QItemList.self, from: data) else {
            return nil
        }
        return wrapper.items
    }
}
