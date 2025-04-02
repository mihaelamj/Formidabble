@testable import SharedModels
import XCTest

final class SharedModelsTests: XCTestCase {
    // MARK: - QItemType Tests

    func testQItemTypeRawValues() {
        XCTAssertEqual(QItemType.page.rawValue, "page")
        XCTAssertEqual(QItemType.section.rawValue, "section")
        XCTAssertEqual(QItemType.question.rawValue, "question")
    }

    // MARK: - QQuestionType Tests

    func testQQuestionTypeRawValues() {
        XCTAssertEqual(QQuestionType.text.rawValue, "text")
        XCTAssertEqual(QQuestionType.image.rawValue, "image")
    }

    // MARK: - QItem Tests

    func testQItemInitialization() {
        let item = QItem(
            type: .page,
            title: "Test Page",
            children: nil,
            questionType: nil,
            imageURL: nil
        )

        XCTAssertEqual(item.type, .page)
        XCTAssertEqual(item.title, "Test Page")
        XCTAssertNil(item.children)
        XCTAssertNil(item.questionType)
        XCTAssertNil(item.imageURL)
    }

    func testQItemWithChildren() {
        let childItem = QItem(
            type: .question,
            title: "Child Question",
            children: nil,
            questionType: .text,
            imageURL: nil
        )

        let parentItem = QItem(
            type: .section,
            title: "Parent Section",
            children: [childItem],
            questionType: nil,
            imageURL: nil
        )

        XCTAssertEqual(parentItem.children?.count, 1)
        XCTAssertEqual(parentItem.children?.first?.title, "Child Question")
    }

    // MARK: - QItem Extensions Tests

    func testDisplayTitle() {
        // Test with title
        let itemWithTitle = QItem(
            type: .page,
            title: "Test Title",
            children: nil,
            questionType: nil,
            imageURL: nil
        )
        XCTAssertEqual(itemWithTitle.displayTitle, "Test Title")

        // Test with no title
        let itemWithNoTitle = QItem(
            type: .question,
            title: nil,
            children: nil,
            questionType: .text,
            imageURL: nil
        )
        XCTAssertEqual(itemWithNoTitle.displayTitle, "")
    }

    func testHasVisibleTitle() {
        // Test with title
        let itemWithTitle = QItem(
            type: .page,
            title: "Test Title",
            children: nil,
            questionType: nil,
            imageURL: nil
        )
        XCTAssertTrue(itemWithTitle.hasVisibleTitle)

        // Test with no title
        let itemWithNoTitle = QItem(
            type: .question,
            title: nil,
            children: nil,
            questionType: .text,
            imageURL: nil
        )
        XCTAssertFalse(itemWithNoTitle.hasVisibleTitle)
    }

    // MARK: - Codable Tests

    func testQItemCodable() throws {
        let json = """
        {
            "type": "page",
            "title": "Main Page",
            "items": [
                {
                    "type": "section",
                    "title": "Introduction",
                    "items": [
                        {
                            "type": "text",
                            "title": "Welcome to the main page!"
                        },
                        {
                            "type": "image",
                            "src": "https://robohash.org/280?&set=set4&size=400x400",
                            "title": "Welcome Image"
                        }
                    ]
                }
            ]
        }
        """.utf8

        let decoder = JSONDecoder()
        let item = try decoder.decode(QItem.self, from: Data(json))

        XCTAssertEqual(item.type, .page)
        XCTAssertEqual(item.title, "Main Page")
        XCTAssertEqual(item.children?.count, 1)
        
        let section = item.children?.first
        XCTAssertEqual(section?.type, .section)
        XCTAssertEqual(section?.title, "Introduction")
        XCTAssertEqual(section?.children?.count, 2)
        
        let textQuestion = section?.children?.first
        XCTAssertEqual(textQuestion?.type, .question)
        XCTAssertEqual(textQuestion?.title, "Welcome to the main page!")
        XCTAssertEqual(textQuestion?.questionType, .text)
        
        let imageQuestion = section?.children?.last
        XCTAssertEqual(imageQuestion?.type, .question)
        XCTAssertEqual(imageQuestion?.title, "Welcome Image")
        XCTAssertEqual(imageQuestion?.questionType, .image)
        XCTAssertEqual(imageQuestion?.imageURL?.absoluteString, "https://robohash.org/280?&set=set4&size=400x400")
    }

    func testQItemWithNestedStructure() throws {
        let json = """
        {
            "type": "section",
            "title": "Chapter 1",
            "items": [
                {
                    "type": "text",
                    "title": "This is the first chapter."
                },
                {
                    "type": "section",
                    "title": "Subsection 1.1",
                    "items": [
                        {
                            "type": "text",
                            "title": "This is a subsection under Chapter 1."
                        },
                        {
                            "type": "image",
                            "src": "https://robohash.org/100?&set=set4&size=400x400",
                            "title": "Chapter 1 Image"
                        }
                    ]
                }
            ]
        }
        """.utf8

        let decoder = JSONDecoder()
        let item = try decoder.decode(QItem.self, from: Data(json))

        XCTAssertEqual(item.type, .section)
        XCTAssertEqual(item.title, "Chapter 1")
        XCTAssertEqual(item.children?.count, 2)
        
        let textQuestion = item.children?.first
        XCTAssertEqual(textQuestion?.type, .question)
        XCTAssertEqual(textQuestion?.title, "This is the first chapter.")
        XCTAssertEqual(textQuestion?.questionType, .text)
        
        let subsection = item.children?.last
        XCTAssertEqual(subsection?.type, .section)
        XCTAssertEqual(subsection?.title, "Subsection 1.1")
        XCTAssertEqual(subsection?.children?.count, 2)
        
        let subsectionText = subsection?.children?.first
        XCTAssertEqual(subsectionText?.type, .question)
        XCTAssertEqual(subsectionText?.title, "This is a subsection under Chapter 1.")
        XCTAssertEqual(subsectionText?.questionType, .text)
        
        let subsectionImage = subsection?.children?.last
        XCTAssertEqual(subsectionImage?.type, .question)
        XCTAssertEqual(subsectionImage?.title, "Chapter 1 Image")
        XCTAssertEqual(subsectionImage?.questionType, .image)
        XCTAssertEqual(subsectionImage?.imageURL?.absoluteString, "https://robohash.org/100?&set=set4&size=400x400")
    }

    func testQItemWithImageCodable() throws {
        let json = """
        {
            "type": "image",
            "title": "Test Image",
            "src": "https://example.com/image.jpg"
        }
        """.utf8

        let decoder = JSONDecoder()
        let item = try decoder.decode(QItem.self, from: Data(json))

        XCTAssertEqual(item.type, .question)
        XCTAssertEqual(item.title, "Test Image")
        XCTAssertEqual(item.questionType, .image)
        XCTAssertEqual(item.imageURL?.absoluteString, "https://example.com/image.jpg")
    }

    func testQItemWithTextQuestionCodable() throws {
        let json = """
        {
            "type": "text",
            "title": "Test Question"
        }
        """.utf8

        let decoder = JSONDecoder()
        let item = try decoder.decode(QItem.self, from: Data(json))

        XCTAssertEqual(item.type, .question)
        XCTAssertEqual(item.title, "Test Question")
        XCTAssertEqual(item.questionType, .text)
        XCTAssertNil(item.imageURL)
    }
}
