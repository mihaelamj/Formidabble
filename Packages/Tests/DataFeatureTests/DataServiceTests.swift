@testable import DataFeature
import SharedModels
import XCTest

final class DataServiceTests: XCTestCase {
    var sut: DataService!
    fileprivate var mockPersistenceManager: MockPersistenceManager!
    fileprivate var mockURLSession: MockURLSession!

    override func setUp() {
        super.setUp()
        mockPersistenceManager = MockPersistenceManager()
        mockURLSession = MockURLSession()
        sut = DataService(persistenceManager: mockPersistenceManager, urlSession: mockURLSession)
    }

    override func tearDown() {
        sut = nil
        mockPersistenceManager = nil
        mockURLSession = nil
        super.tearDown()
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

    func testFetchDataSuccess() async throws {
        // Given
        let expectedItems = [QItem(id: "1", type: .page, title: "Test Item")]
        let encoder = JSONEncoder()
        let mockData = try encoder.encode(expectedItems)
        mockURLSession.mockResponseData = mockData

        // When
        let items = try await sut.fetchData()

        // Then
        XCTAssertEqual(items, expectedItems)
        let saveItemsCalled = await mockPersistenceManager.saveItemsCalled
        XCTAssertTrue(saveItemsCalled)
    }

    func testFetchDataWithCacheFallback() async throws {
        // Given
        let cachedItems = [QItem(id: "1", type: .page, title: "Cached Item")]
        await mockPersistenceManager.setMockItems(cachedItems)
        mockURLSession.shouldSimulateError = true
        // Note: shouldSimulateLoadError is not set, so cached items will be returned

        // When
        let items = try await sut.fetchData()

        // Then
        XCTAssertEqual(items, cachedItems)
    }

    func testFetchDataWithBundledFallback() async throws {
        // Given
        mockURLSession.shouldSimulateError = true
        await mockPersistenceManager.setShouldSimulateLoadError(true)
        // This will cause loadItems to return nil, forcing bundled data fallback

        // When
        let items = try await sut.fetchData()

        // Then
        XCTAssertFalse(items.isEmpty)
    }
}

// MARK: - Mock PersistenceManager

private actor MockPersistenceManager: PersistenceManaging {
    private var mockItems: [QItem]?
    private var shouldSimulateError = false
    private var shouldSimulateLoadError = false
    private(set) var saveItemsCalled = false

    func setMockItems(_ items: [QItem]?) {
        mockItems = items
    }

    func setShouldSimulateError(_ value: Bool) {
        shouldSimulateError = value
    }

    func setShouldSimulateLoadError(_ value: Bool) {
        shouldSimulateLoadError = value
    }

    func saveItems(_ items: [QItem]) {
        saveItemsCalled = true
        if shouldSimulateError {
            return
        }
        mockItems = items
    }

    func loadItems() -> [QItem]? {
        if shouldSimulateLoadError {
            return nil
        }
        // If mockItems is nil, this simulates the case where no file exists
        return mockItems
    }
}

// MARK: - Mock URLSession

private class MockURLSession: URLSessionProtocol, @unchecked Sendable {
    var shouldSimulateError = false
    var mockResponseData: Data?

    func data(from url: URL) async throws -> (Data, URLResponse) {
        if shouldSimulateError {
            throw NSError(domain: "com.test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Simulated network error"])
        }

        if let mockData = mockResponseData {
            return (mockData, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }

        return (Data(), HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
    }
}
