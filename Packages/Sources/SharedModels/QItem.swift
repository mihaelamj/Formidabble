import Foundation

public enum QItemType: String, Codable, Sendable {
    case page = "Page"
    case section = "Section"
    case question = "Question"
}

public enum QQuestionType: String, Codable, Sendable {
    case text
    case image
}

public struct QItem: Identifiable, Codable, Sendable, Equatable {
    public let id: String // changed from UUID to match "page1", "q1", etc.
    public let type: QItemType
    public let title: String?
    public let children: [QItem]?

    public let questionType: QQuestionType?
    public let content: String?
    public let imageURL: URL?

    public init(
        id: String,
        type: QItemType,
        title: String? = nil,
        children: [QItem]? = nil,
        questionType: QQuestionType? = nil,
        content: String? = nil,
        imageURL: URL? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.children = children
        self.questionType = questionType
        self.content = content
        self.imageURL = imageURL
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type = "itemType"
        case title
        case children = "items"
        case questionType
        case content = "text"
        case imageURL = "imageUrl"
    }
    
    public static func == (lhs: QItem, rhs: QItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        lhs.title == rhs.title &&
        lhs.questionType == rhs.questionType &&
        lhs.content == rhs.content &&
        lhs.imageURL == rhs.imageURL &&
        lhs.children == rhs.children
    }
}

public struct QItemList: Codable {
    public let items: [QItem]
}

public extension QItem {
    var displayTitle: String {
        title ?? content ?? ""
    }

    var hasVisibleTitle: Bool {
        !(displayTitle.isEmpty)
    }
}
