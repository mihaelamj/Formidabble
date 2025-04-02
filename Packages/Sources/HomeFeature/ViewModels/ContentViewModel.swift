import SwiftUI
import DataFeature

@Observable
@MainActor
final class ContentViewModel {

    enum LoadState {
        case idle, loading, loaded, error(Error)

        enum Kind {
            case idle, loading, loaded, error
        }

        var kind: Kind {
            switch self {
            case .idle: return .idle
            case .loading: return .loading
            case .loaded: return .loaded
            case .error: return .error
            }
        }
    }

    private let dataService: DataService
    private var isUsingCachedDataFlag = false

    var itemViewModels: [QItemViewModel] = []
    var loadState: LoadState = .idle

    var isUsingCachedData: Bool {
        isUsingCachedDataFlag
    }

    init(dataService: DataService) {
        self.dataService = dataService
    }

    func loadData() async {
        loadState = .loading
        isUsingCachedDataFlag = false

        do {
            let items = try await dataService.fetchData()
            itemViewModels = items.map { QItemViewModel(item: $0) }
            loadState = .loaded

            // Check if we're using cached data by examining the DataService
            isUsingCachedDataFlag = await dataService.isUsingCachedData
        } catch {
            loadState = .error(error)
        }
    }

    func setAllExpanded(_ expanded: Bool) {
        for vm in itemViewModels {
            vm.setRecursively(expanded: expanded)
        }
    }
}
