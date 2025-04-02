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

    private func createTestItems() -> QItem {
        QItem(
            type: .page,
            title: "Test Page",
            children: [
                QItem(
                    type: .section,
                    title: "Test Section",
                    children: [
                        QItem(
                            type: .question,
                            title: "Test Question",
                            children: nil,
                            questionType: .text,
                            imageURL: nil
                        ),
                    ],
                    questionType: nil,
                    imageURL: nil
                ),
            ],
            questionType: nil,
            imageURL: nil
        )
    }

    // MARK: - Tests

    func testSaveAndLoadItems() async {
        // Given
        let testItem = createTestItems()

        // When
        await persistenceManager.saveItems(testItem)
        let loadedItem = await persistenceManager.loadItems()

        // Then
        XCTAssertNotNil(loadedItem)
        XCTAssertEqual(loadedItem?.type, testItem.type)
        XCTAssertEqual(loadedItem?.title, testItem.title)
        XCTAssertEqual(loadedItem?.children?.count, testItem.children?.count)
        XCTAssertEqual(loadedItem?.children?.first?.type, testItem.children?.first?.type)
        XCTAssertEqual(loadedItem?.children?.first?.title, testItem.children?.first?.title)
    }

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

    func testSaveAndLoadItemsWithNestedStructure() async {
        // Given
        let testItem = createTestItems()

        // When
        await persistenceManager.saveItems(testItem)
        let loadedItem = await persistenceManager.loadItems()

        // Then
        XCTAssertNotNil(loadedItem)
        XCTAssertEqual(loadedItem?.type, .page)
        XCTAssertEqual(loadedItem?.title, "Test Page")

        // Check nested structure
        let loadedSection = loadedItem?.children?.first
        XCTAssertNotNil(loadedSection)
        XCTAssertEqual(loadedSection?.type, .section)
        XCTAssertEqual(loadedSection?.title, "Test Section")
        XCTAssertEqual(loadedSection?.children?.count, 1)
        XCTAssertEqual(loadedSection?.children?.first?.type, .question)
        XCTAssertEqual(loadedSection?.children?.first?.questionType, .text)
        XCTAssertEqual(loadedSection?.children?.first?.title, "Test Question")
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
