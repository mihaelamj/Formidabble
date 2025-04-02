import SwiftUI
import SharedModels

@Observable
final class QItemViewModel: Identifiable {
    let id = UUID()
    let item: QItem
    var isExpanded: Bool = true
    var children: [QItemViewModel]

    init(item: QItem) {
        self.item = item
        self.children = item.children?.map { QItemViewModel(item: $0) } ?? []
    }

    func setRecursively(expanded: Bool) {
        isExpanded = expanded
        for child in children {
            child.setRecursively(expanded: expanded)
        }
    }
}
