import XCTest
import DataFeature
import SharedModels

final class DataServiceTests: XCTestCase {
    private var sut: DataService!
    private var mockPersistenceManager: MockPersistenceManager!
    private var mockURLSession: MockURLSession!

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

    func testFetchDataWithCacheFallback() async throws {
        // Given
        let cachedItem = createTestItems()
        await mockPersistenceManager.setMockItems(cachedItem)
        mockURLSession.shouldSimulateError = true

        // When
        let result = try await sut.fetchData()

        // Then
        XCTAssertEqual(result.type, cachedItem.type)
        XCTAssertEqual(result.title, cachedItem.title)
        XCTAssertEqual(result.children?.count, cachedItem.children?.count)
        XCTAssertEqual(result.children?.first?.type, cachedItem.children?.first?.type)
        XCTAssertEqual(result.children?.first?.title, cachedItem.children?.first?.title)
        XCTAssertEqual(result.children?.first?.children?.first?.type, cachedItem.children?.first?.children?.first?.type)
        XCTAssertEqual(result.children?.first?.children?.first?.title, cachedItem.children?.first?.children?.first?.title)
        XCTAssertEqual(result.children?.first?.children?.first?.questionType, cachedItem.children?.first?.children?.first?.questionType)
    }

    func testFetchDataWithBundledFallback() async throws {
        // Given
        mockURLSession.shouldSimulateError = true
        await mockPersistenceManager.setShouldSimulateLoadError(true)

        // When
        let result = try await sut.fetchData()

        // Then
        XCTAssertEqual(result.type, .page)
        XCTAssertEqual(result.title, "Main Page")
        XCTAssertEqual(result.children?.count, 4)
        XCTAssertEqual(result.children?.first?.type, .page)
        XCTAssertEqual(result.children?.first?.title, "Personal Information")
        XCTAssertEqual(result.children?.first?.children?.count, 2)
        XCTAssertEqual(result.children?.first?.children?.first?.type, .section)
        XCTAssertEqual(result.children?.first?.children?.first?.title, "Basic Details")
        XCTAssertEqual(result.children?.first?.children?.first?.children?.count, 3)
        XCTAssertEqual(result.children?.first?.children?.first?.children?.first?.type, .question)
        XCTAssertEqual(result.children?.first?.children?.first?.children?.first?.title, "What is your full name?")
        XCTAssertEqual(result.children?.first?.children?.first?.children?.first?.questionType, .text)
    }

    func testLoadTestFormFromResources() throws {
        // Given
        guard let url = Bundle.module.url(forResource: "TestForm", withExtension: "json") else {
            XCTFail("TestForm.json not found in resources")
            return
        }

        // When
        let data = try Data(contentsOf: url)
        let item = try JSONDecoder().decode(QItem.self, from: data)

        // Then
        XCTAssertEqual(item.type, .page)
        XCTAssertEqual(item.title, "Main Page")
        XCTAssertEqual(item.children?.count, 4)

        // Check Personal Information page
        let personalInfoPage = item.children?.first
        XCTAssertEqual(personalInfoPage?.type, .page)
        XCTAssertEqual(personalInfoPage?.title, "Personal Information")
        XCTAssertEqual(personalInfoPage?.children?.count, 2)

        let basicDetailsSection = personalInfoPage?.children?.first
        XCTAssertEqual(basicDetailsSection?.type, .section)
        XCTAssertEqual(basicDetailsSection?.title, "Basic Details")
        XCTAssertEqual(basicDetailsSection?.children?.count, 3)

        let nameQuestion = basicDetailsSection?.children?.first
        XCTAssertEqual(nameQuestion?.type, .question)
        XCTAssertEqual(nameQuestion?.title, "What is your full name?")
        XCTAssertEqual(nameQuestion?.questionType, .text)

        let idPhotoQuestion = basicDetailsSection?.children?.last
        XCTAssertEqual(idPhotoQuestion?.type, .question)
        XCTAssertEqual(idPhotoQuestion?.title, "Upload a photo of your ID.")
        XCTAssertEqual(idPhotoQuestion?.questionType, .image)
        XCTAssertEqual(idPhotoQuestion?.imageURL?.absoluteString, "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=2070&auto=format&fit=crop")

        // Check Contact Information section
        let contactSection = personalInfoPage?.children?.last
        XCTAssertEqual(contactSection?.type, .section)
        XCTAssertEqual(contactSection?.title, "Contact Information")
        XCTAssertEqual(contactSection?.children?.count, 3)

        let addressSection = contactSection?.children?.last
        XCTAssertEqual(addressSection?.type, .section)
        XCTAssertEqual(addressSection?.title, "Address Details")
        XCTAssertEqual(addressSection?.children?.count, 2)

        // Check Interests and Hobbies page
        let interestsPage = item.children?[1]
        XCTAssertEqual(interestsPage?.type, .page)
        XCTAssertEqual(interestsPage?.title, "Interests and Hobbies")
        XCTAssertEqual(interestsPage?.children?.count, 2)

        // Check Travel Experiences page
        let travelPage = item.children?[2]
        XCTAssertEqual(travelPage?.type, .page)
        XCTAssertEqual(travelPage?.title, "Travel Experiences")
        XCTAssertEqual(travelPage?.children?.count, 3)

        // Check Work and Education page
        let workPage = item.children?.last
        XCTAssertEqual(workPage?.type, .page)
        XCTAssertEqual(workPage?.title, "Work and Education")
        XCTAssertEqual(workPage?.children?.count, 2)

        let educationSection = workPage?.children?.first
        XCTAssertEqual(educationSection?.type, .section)
        XCTAssertEqual(educationSection?.title, "Education History")
        XCTAssertEqual(educationSection?.children?.count, 3)

        let certificationsSection = educationSection?.children?.last
        XCTAssertEqual(certificationsSection?.type, .section)
        XCTAssertEqual(certificationsSection?.title, "Certifications")
        XCTAssertEqual(certificationsSection?.children?.count, 2)

        let certificatePhoto = certificationsSection?.children?.last
        XCTAssertEqual(certificatePhoto?.type, .question)
        XCTAssertEqual(certificatePhoto?.title, "Upload a photo of your certificate.")
        XCTAssertEqual(certificatePhoto?.questionType, .image)
        XCTAssertEqual(certificatePhoto?.imageURL?.absoluteString, "https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?q=80&w=2070&auto=format&fit=crop")
    }
}

// MARK: - Mock PersistenceManager

private actor MockPersistenceManager: PersistenceManaging {
    private var mockItems: QItem?
    private var shouldSimulateError = false
    private var shouldSimulateLoadError = false
    private(set) var saveItemsCalled = false

    func setMockItems(_ items: QItem?) {
        mockItems = items
    }

    func setShouldSimulateError(_ value: Bool) {
        shouldSimulateError = value
    }

    func setShouldSimulateLoadError(_ value: Bool) {
        shouldSimulateLoadError = value
    }

    func saveItems(_ items: QItem) {
        saveItemsCalled = true
        if shouldSimulateError {
            return
        }
        mockItems = items
    }

    func loadItems() -> QItem? {
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
