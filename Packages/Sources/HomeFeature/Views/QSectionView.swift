import SwiftUI

struct QSectionView: View {
    let viewModel: QItemViewModel
    let depth: Int

    var fontSize: CGFloat {
        max(18 - CGFloat(depth * 2), 14)
    }

    var body: some View {
        DisclosureGroup(isExpanded: Binding(
            get: { viewModel.isExpanded },
            set: { viewModel.isExpanded = $0 }
        )) {
            ForEach(viewModel.children) { child in
                QItemView(viewModel: child, depth: depth + 1)
            }
        } label: {
            optionalTitle(
                viewModel.item.displayTitle,
                font: .system(size: fontSize, weight: .semibold),
                leading: CGFloat(depth * 8)
            )
        }
    }
}
