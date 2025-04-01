import Foundation
import SharedModels

public actor DataService {
    private let apiURL = URL(string: "https://run.mocky.io/v3/1800b96f-c579-49e5-b0b8-49856a36ce39")!
    private let persistenceManager: PersistenceManager

    public init(persistenceManager: PersistenceManager) {
        self.persistenceManager = persistenceManager
    }

    public func fetchData() async throws -> [QItem] {
        do {
            let (data, _) = try await URLSession.shared.data(from: apiURL)
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
