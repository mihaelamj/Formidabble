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

    // MARK: - Test Data

    private func createTestItems() -> [QItem] {
        [
            QItem(
                id: "page1",
                type: .page,
                title: "Test Page",
                children: nil,
                questionType: nil,
                content: nil,
                imageURL: nil
            ),
            QItem(
                id: "section1",
                type: .section,
                title: "Test Section",
                children: [
                    QItem(
                        id: "question1",
                        type: .question,
                        title: "Test Question",
                        children: nil,
                        questionType: .text,
                        content: "Question content",
                        imageURL: nil
                    ),
                ],
                questionType: nil,
                content: nil,
                imageURL: nil
            ),
        ]
    }

    // MARK: - Tests

    func testSaveAndLoadItems() async {
        // Given
        let testItems = createTestItems()

        // When
        await persistenceManager.saveItems(testItems)
        let loadedItems = await persistenceManager.loadItems()

        // Then
        XCTAssertNotNil(loadedItems)
        XCTAssertEqual(loadedItems?.count, testItems.count)
        XCTAssertEqual(loadedItems?.first?.id, testItems.first?.id)
        XCTAssertEqual(loadedItems?.first?.type, testItems.first?.type)
        XCTAssertEqual(loadedItems?.first?.title, testItems.first?.title)
    }

    func testLoadItemsWhenFileDoesNotExist() async {
        // When
        let loadedItems = await persistenceManager.loadItems()

        // Then
        XCTAssertNil(loadedItems)
    }

    func testSaveAndLoadEmptyItems() async {
        // Given
        let emptyItems: [QItem] = []

        // When
        await persistenceManager.saveItems(emptyItems)
        let loadedItems = await persistenceManager.loadItems()

        // Then
        XCTAssertNotNil(loadedItems)
        XCTAssertEqual(loadedItems?.count, 0)
    }

    func testSaveAndLoadItemsWithNestedStructure() async {
        // Given
        let testItems = createTestItems()

        // When
        await persistenceManager.saveItems(testItems)
        let loadedItems = await persistenceManager.loadItems()

        // Then
        XCTAssertNotNil(loadedItems)
        XCTAssertEqual(loadedItems?.count, testItems.count)

        // Check nested structure
        let loadedSection = loadedItems?.first { $0.type == .section }
        XCTAssertNotNil(loadedSection)
        XCTAssertEqual(loadedSection?.children?.count, 1)
        XCTAssertEqual(loadedSection?.children?.first?.type, .question)
        XCTAssertEqual(loadedSection?.children?.first?.questionType, .text)
    }

    func testSaveItemsOverwriteExisting() async {
        // Given
        let initialItems = [
            QItem(
                id: "old1",
                type: .page,
                title: "Old Page",
                children: nil,
                questionType: nil,
                content: nil,
                imageURL: nil
            ),
        ]

        let newItems = [
            QItem(
                id: "new1",
                type: .page,
                title: "New Page",
                children: nil,
                questionType: nil,
                content: nil,
                imageURL: nil
            ),
        ]

        // When
        await persistenceManager.saveItems(initialItems)
        await persistenceManager.saveItems(newItems)
        let loadedItems = await persistenceManager.loadItems()

        // Then
        XCTAssertNotNil(loadedItems)
        XCTAssertEqual(loadedItems?.count, 1)
        XCTAssertEqual(loadedItems?.first?.id, "new1")
        XCTAssertEqual(loadedItems?.first?.title, "New Page")
    }
}
