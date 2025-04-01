import Foundation

enum QItemType: String, Codable, Sendable {
    case page = "Page"
    case section = "Section"
    case question = "Question"
}

enum QQuestionType: String, Codable, Sendable {
    case text
    case image
}

public struct QItem: Identifiable, Codable, Sendable {
    public let id: String // changed from UUID to match "page1", "q1", etc.
    let type: QItemType
    let title: String?
    let children: [QItem]?

    let questionType: QQuestionType?
    let content: String?
    let imageURL: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case type = "itemType"
        case title
        case children = "items"
        case questionType
        case content = "text"
        case imageURL = "imageUrl"
    }
}

public struct QItemList: Codable {
    public let items: [QItem]
}


extension QItem {
    var displayTitle: String {
        title ?? content ?? ""
    }

    var hasVisibleTitle: Bool {
        !(displayTitle.isEmpty)
    }
}
