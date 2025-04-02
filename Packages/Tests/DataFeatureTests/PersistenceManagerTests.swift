@testable import DataFeature
import SharedModels
import XCTest

final class PersistenceManagerTests: XCTestCase {
    var persistenceManager: PersistenceManager!
    var testCacheDirectory: URL!

    override func setUp() async throws {
        try await super.setUp()

        // Create a temporary directory for testing
        testCacheDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: testCacheDirectory, withIntermediateDirectories: true)

        persistenceManager = PersistenceManager()
    }

    override func tearDown() async throws {
        // Clean up the test directory
        try? FileManager.default.removeItem(at: testCacheDirectory)
        persistenceManager = nil
        try await super.tearDown()
    }

    // MARK: - Tests

    func testSaveAndLoadEmptyItems() async {
        // Given
        let emptyItem = QItem(
            type: .page,
            title: "Empty Page",
            children: [],
            questionType: nil,
            imageURL: nil
        )

        // When
        await persistenceManager.saveItems(emptyItem)
        let loadedItem = await persistenceManager.loadItems()

        // Then
        XCTAssertNotNil(loadedItem)
        XCTAssertEqual(loadedItem?.type, .page)
        XCTAssertEqual(loadedItem?.title, "Empty Page")
        XCTAssertEqual(loadedItem?.children?.count, 0)
    }

    func testSaveItemsOverwriteExisting() async {
        // Given
        let initialItem = QItem(
            type: .page,
            title: "Old Page",
            children: nil,
            questionType: nil,
            imageURL: nil
        )

        let newItem = QItem(
            type: .page,
            title: "New Page",
            children: nil,
            questionType: nil,
            imageURL: nil
        )

        // When
        await persistenceManager.saveItems(initialItem)
        await persistenceManager.saveItems(newItem)
        let loadedItem = await persistenceManager.loadItems()

        // Then
        XCTAssertNotNil(loadedItem)
        XCTAssertEqual(loadedItem?.type, .page)
        XCTAssertEqual(loadedItem?.title, "New Page")
    }
}
