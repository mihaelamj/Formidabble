import Foundation
import SharedModels

public protocol PersistenceManaging: Actor {
    func saveItems(_ item: QItem)
    func loadItems() -> QItem?
}

public actor PersistenceManager: PersistenceManaging {
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    private static let fileName = "cached_items.json"

    public init() {
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first! // swiftlint:disable:this force_unwrapping
    }

    public func saveItems(_ item: QItem) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(item)
            let fileURL = cacheDirectory.appendingPathComponent(Self.fileName)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save items: \(error)")
        }
    }

    public func loadItems() -> QItem? {
        let fileURL = cacheDirectory.appendingPathComponent(Self.fileName)

        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }

        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(QItem.self, from: data)
        } catch {
            print("Failed to load cached items: \(error)")
            return nil
        }
    }
}
