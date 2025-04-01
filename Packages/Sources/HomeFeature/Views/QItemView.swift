import SwiftUI

struct QItemView: View {
    let viewModel: QItemViewModel
    let depth: Int

    var body: some View {
        switch viewModel.item.type {
        case .page:
            QPageView(viewModel: viewModel, depth: depth)
        case .section:
            QSectionView(viewModel: viewModel, depth: depth)
        case .question:
            QQuestionView(item: viewModel.item)
        }
    }
}
