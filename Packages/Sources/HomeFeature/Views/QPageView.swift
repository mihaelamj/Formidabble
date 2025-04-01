import SwiftUI

struct QPageView: View {
    let viewModel: QItemViewModel
    let depth: Int

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
                font: .system(size: max(24 - CGFloat(depth), 16), weight: .bold),
                leading: CGFloat(depth * 8)
            )
        }
    }
}
