import XCTest
import HomeFeature
import DataFeature
import SharedModels

@MainActor
final class HomeFeatureTests: XCTestCase {
    var sut: ContentViewModel!
    var mockDataService: MockDataService!
    var mockPersistenceManager: MockPersistenceManager!

    override func setUp() async throws {
        try await super.setUp()
        mockPersistenceManager = MockPersistenceManager()
        mockDataService = MockDataService(persistenceManager: mockPersistenceManager)
        sut = ContentViewModel(dataService: mockDataService)
    }

    override func tearDown() async throws {
        sut = nil
        mockDataService = nil
        mockPersistenceManager = nil
        try await super.tearDown()
    }

    // MARK: - ContentViewModel Tests

    func testContentViewModelInitialState() async {
        XCTAssertEqual(sut.loadState, .idle)
        XCTAssertTrue(sut.itemViewModels.isEmpty)
    }

    func testContentViewModelLoadDataSuccess() async {
        // Given
        let mockItems = [
            QItem(id: "1", text: "Item 1", children: []),
            QItem(id: "2", text: "Item 2", children: []),
        ]
        mockDataService.mockItems = mockItems

        // When
        await sut.loadData()

        // Then
        XCTAssertEqual(sut.loadState, .loaded)
        XCTAssertEqual(sut.itemViewModels.count, 2)
        XCTAssertEqual(sut.itemViewModels[0].item.id, "1")
        XCTAssertEqual(sut.itemViewModels[1].item.id, "2")
    }

    func testContentViewModelLoadDataFailure() async {
        // Given
        let mockError = NSError(domain: "com.test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        mockDataService.shouldSimulateError = true
        mockDataService.mockError = mockError

        // When
        await sut.loadData()

        // Then
        if case .error(let error) = sut.loadState {
            XCTAssertEqual(error.localizedDescription, "Test error")
        } else {
            XCTFail("Expected error state, got \(sut.loadState)")
        }
    }

    func testContentViewModelSetAllExpanded() async {
        // Given
        let mockItems = [
            QItem(id: "1", text: "Item 1", children: [
                QItem(id: "1.1", text: "Item 1.1", children: []),
                QItem(id: "1.2", text: "Item 1.2", children: []),
            ]),
            QItem(id: "2", text: "Item 2", children: []),
        ]
        mockDataService.mockItems = mockItems
        await sut.loadData()

        // When - Expand all
        sut.setAllExpanded(true)

        // Then
        XCTAssertTrue(sut.itemViewModels[0].isExpanded)
        XCTAssertTrue(sut.itemViewModels[0].children[0].isExpanded)
        XCTAssertTrue(sut.itemViewModels[0].children[1].isExpanded)
        XCTAssertTrue(sut.itemViewModels[1].isExpanded)

        // When - Collapse all
        sut.setAllExpanded(false)

        // Then
        XCTAssertFalse(sut.itemViewModels[0].isExpanded)
        XCTAssertFalse(sut.itemViewModels[0].children[0].isExpanded)
        XCTAssertFalse(sut.itemViewModels[0].children[1].isExpanded)
        XCTAssertFalse(sut.itemViewModels[1].isExpanded)
    }

    func testContentViewModelUsingCachedData() async {
        // Given
        let mockItems = [
            QItem(id: "1", text: "Item 1", children: []),
            QItem(id: "2", text: "Item 2", children: []),
        ]
        mockDataService.mockItems = mockItems
        mockDataService.shouldUseCachedData = true

        // When
        await sut.loadData()

        // Then
        XCTAssertEqual(sut.loadState, .loaded)
        XCTAssertTrue(await sut.isUsingCachedData)
    }

    // MARK: - QItemViewModel Tests

    func testQItemViewModelToggleExpanded() async {
        // Given
        let mockItems = [
            QItem(id: "1", text: "Item 1", children: [
                QItem(id: "1.1", text: "Item 1.1", children: []),
                QItem(id: "1.2", text: "Item 1.2", children: []),
            ]),
        ]
        mockDataService.mockItems = mockItems
        await sut.loadData()

        let itemVM = sut.itemViewModels[0]

        // When - Expand
        itemVM.toggleExpanded()

        // Then
        XCTAssertTrue(itemVM.isExpanded)
        XCTAssertTrue(itemVM.children[0].isExpanded)
        XCTAssertTrue(itemVM.children[1].isExpanded)

        // When - Collapse
        itemVM.toggleExpanded()

        // Then
        XCTAssertFalse(itemVM.isExpanded)
        XCTAssertFalse(itemVM.children[0].isExpanded)
        XCTAssertFalse(itemVM.children[1].isExpanded)
    }

    func testQItemViewModelSetRecursively() async {
        // Given
        let mockItems = [
            QItem(id: "1", text: "Item 1", children: [
                QItem(id: "1.1", text: "Item 1.1", children: [
                    QItem(id: "1.1.1", text: "Item 1.1.1", children: [])
                ]),
                QItem(id: "1.2", text: "Item 1.2", children: []),
            ]),
        ]
        mockDataService.mockItems = mockItems
        await sut.loadData()

        let itemVM = sut.itemViewModels[0]

        // When - Expand recursively
        itemVM.setRecursively(expanded: true)

        // Then
        XCTAssertTrue(itemVM.isExpanded)
        XCTAssertTrue(itemVM.children[0].isExpanded)
        XCTAssertTrue(itemVM.children[0].children[0].isExpanded)
        XCTAssertTrue(itemVM.children[1].isExpanded)

        // When - Collapse recursively
        itemVM.setRecursively(expanded: false)

        // Then
        XCTAssertFalse(itemVM.isExpanded)
        XCTAssertFalse(itemVM.children[0].isExpanded)
        XCTAssertFalse(itemVM.children[0].children[0].isExpanded)
        XCTAssertFalse(itemVM.children[1].isExpanded)
    }
}

// MARK: - Mock DataService

class MockDataService: DataService {
    var mockItems: [QItem] = []
    var shouldSimulateError = false
    var mockError: Error?
    var shouldUseCachedData = false

    override func fetchData() async throws -> [QItem] {
        if shouldSimulateError {
            throw mockError ?? NSError(domain: "com.test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        }

        if shouldUseCachedData {
            return mockItems
        }

        return mockItems
    }
}

// MARK: - Mock PersistenceManager

class MockPersistenceManager: PersistenceManaging {
    var savedItems: [QItem] = []

    func saveItems(_ items: [QItem]) async {
        savedItems = items
    }

    func loadItems() async -> [QItem]? {
        return savedItems.isEmpty ? nil : savedItems
    }
}
