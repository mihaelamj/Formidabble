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
    public let id: String
    public let type: QItemType
    public let title: String?
    public let children: [QItem]?
    public let questionType: QQuestionType?
    public let imageURL: URL?
    
    public init(
        id: String,
        type: QItemType,
        title: String? = nil,
        children: [QItem]? = nil,
        questionType: QQuestionType? = nil,
        imageURL: URL? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.children = children
        self.questionType = questionType
        self.imageURL = imageURL
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case title
        case children = "items"
        case questionType
        case imageURL = "src"
    }
    
    public static func == (lhs: QItem, rhs: QItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        lhs.title == rhs.title &&
        lhs.questionType == rhs.questionType &&
        lhs.imageURL == rhs.imageURL &&
        lhs.children == rhs.children
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        let typeString = try container.decode(String.self, forKey: .type)
        
        switch typeString {
        case "page":
            type = .page
            questionType = nil
        case "section":
            type = .section
            questionType = nil
        case "text":
            type = .question
            questionType = .text
        case "image":
            type = .question
            questionType = .image
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Invalid item type: \(typeString)"
            )
        }
        
        title = try container.decodeIfPresent(String.self, forKey: .title)
        children = try container.decodeIfPresent([QItem].self, forKey: .children)
        imageURL = try container.decodeIfPresent(URL.self, forKey: .imageURL)
    }
}

public extension QItem {
    var displayTitle: String {
        title ?? ""
    }
    
    var hasVisibleTitle: Bool {
        !(displayTitle.isEmpty)
    }
}
