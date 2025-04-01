import Foundation

actor PersistenceManager {
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private static let fileName = "cached_items.json"
    
    init() {
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    func saveItems(_ items: [QItem]) async {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(items)
            let fileURL = cacheDirectory.appendingPathComponent(Self.fileName)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save items: \(error)")
        }
    }
    
    func loadItems() async -> [QItem]? {
        let fileURL = cacheDirectory.appendingPathComponent(Self.fileName)
        
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([QItem].self, from: data)
        } catch {
            print("Failed to load cached items: \(error)")
            return nil
        }
    }
}
