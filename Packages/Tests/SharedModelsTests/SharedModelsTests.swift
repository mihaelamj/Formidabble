@testable import SharedModels
import XCTest

final class SharedModelsTests: XCTestCase {
    // MARK: - QItemType Tests

    func testQItemTypeRawValues() {
        XCTAssertEqual(QItemType.page.rawValue, "Page")
        XCTAssertEqual(QItemType.section.rawValue, "Section")
        XCTAssertEqual(QItemType.question.rawValue, "Question")
    }

    // MARK: - QQuestionType Tests

    func testQQuestionTypeRawValues() {
        XCTAssertEqual(QQuestionType.text.rawValue, "text")
        XCTAssertEqual(QQuestionType.image.rawValue, "image")
    }

    // MARK: - QItem Tests

    func testQItemInitialization() {
        let item = QItem(
            id: "test1",
            type: .page,
            title: "Test Page",
            children: nil,
            questionType: nil,
            content: nil,
            imageURL: nil
        )

        XCTAssertEqual(item.id, "test1")
        XCTAssertEqual(item.type, .page)
        XCTAssertEqual(item.title, "Test Page")
        XCTAssertNil(item.children)
        XCTAssertNil(item.questionType)
        XCTAssertNil(item.content)
        XCTAssertNil(item.imageURL)
    }

    func testQItemWithChildren() {
        let childItem = QItem(
            id: "child1",
            type: .question,
            title: "Child Question",
            children: nil,
            questionType: .text,
            content: "Question content",
            imageURL: nil
        )

        let parentItem = QItem(
            id: "parent1",
            type: .section,
            title: "Parent Section",
            children: [childItem],
            questionType: nil,
            content: nil,
            imageURL: nil
        )

        XCTAssertEqual(parentItem.children?.count, 1)
        XCTAssertEqual(parentItem.children?.first?.id, "child1")
    }

    // MARK: - QItem Extensions Tests

    func testDisplayTitle() {
        // Test with title
        let itemWithTitle = QItem(
            id: "test1",
            type: .page,
            title: "Test Title",
            children: nil,
            questionType: nil,
            content: nil,
            imageURL: nil
        )
        XCTAssertEqual(itemWithTitle.displayTitle, "Test Title")

        // Test with content (no title)
        let itemWithContent = QItem(
            id: "test2",
            type: .question,
            title: nil,
            children: nil,
            questionType: .text,
            content: "Test Content",
            imageURL: nil
        )
        XCTAssertEqual(itemWithContent.displayTitle, "Test Content")

        // Test with no title or content
        let itemWithNoTitleOrContent = QItem(
            id: "test3",
            type: .page,
            title: nil,
            children: nil,
            questionType: nil,
            content: nil,
            imageURL: nil
        )
        XCTAssertEqual(itemWithNoTitleOrContent.displayTitle, "")
    }

    func testHasVisibleTitle() {
        // Test with title
        let itemWithTitle = QItem(
            id: "test1",
            type: .page,
            title: "Test Title",
            children: nil,
            questionType: nil,
            content: nil,
            imageURL: nil
        )
        XCTAssertTrue(itemWithTitle.hasVisibleTitle)

        // Test with content (no title)
        let itemWithContent = QItem(
            id: "test2",
            type: .question,
            title: nil,
            children: nil,
            questionType: .text,
            content: "Test Content",
            imageURL: nil
        )
        XCTAssertTrue(itemWithContent.hasVisibleTitle)

        // Test with no title or content
        let itemWithNoTitleOrContent = QItem(
            id: "test3",
            type: .page,
            title: nil,
            children: nil,
            questionType: nil,
            content: nil,
            imageURL: nil
        )
        XCTAssertFalse(itemWithNoTitleOrContent.hasVisibleTitle)
    }

    // MARK: - Codable Tests

    func testQItemCodable() throws {
        let json = """
        {
            "id": "test1",
            "itemType": "Page",
            "title": "Test Page",
            "items": null,
            "questionType": null,
            "text": null,
            "imageUrl": null
        }
        """.utf8

        let decoder = JSONDecoder()
        let item = try decoder.decode(QItem.self, from: Data(json))

        XCTAssertEqual(item.id, "test1")
        XCTAssertEqual(item.type, .page)
        XCTAssertEqual(item.title, "Test Page")
        XCTAssertNil(item.children)
        XCTAssertNil(item.questionType)
        XCTAssertNil(item.content)
        XCTAssertNil(item.imageURL)
    }

    func testQItemListCodable() throws {
        let json = """
        {
            "items": [
                {
                    "id": "page1",
                    "itemType": "Page",
                    "title": "Page 1",
                    "items": null,
                    "questionType": null,
                    "text": null,
                    "imageUrl": null
                }
            ]
        }
        """.utf8

        let decoder = JSONDecoder()
        let itemList = try decoder.decode(QItemList.self, from: Data(json))

        XCTAssertEqual(itemList.items.count, 1)
        XCTAssertEqual(itemList.items.first?.id, "page1")
        XCTAssertEqual(itemList.items.first?.type, .page)
        XCTAssertEqual(itemList.items.first?.title, "Page 1")
    }
}
