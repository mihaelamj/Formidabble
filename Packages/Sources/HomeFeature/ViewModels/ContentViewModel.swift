import SwiftUI
import DataFeature

@Observable
@MainActor
public final class ContentViewModel {

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

    var rootItemViewModel: QItemViewModel?
    var loadState: LoadState = .idle

    var isUsingCachedData: Bool {
        isUsingCachedDataFlag
    }

    public init(dataService: DataService) {
        self.dataService = dataService
    }

    public func loadData() async {
        loadState = .loading
        isUsingCachedDataFlag = false

        do {
            let rootItem = try await dataService.fetchData()
            rootItemViewModel = QItemViewModel(item: rootItem)
            loadState = .loaded

            // Check if we're using cached data by examining the DataService
            isUsingCachedDataFlag = await dataService.isUsingCachedData
        } catch {
            loadState = .error(error)
        }
    }

    func setAllExpanded(_ expanded: Bool) {
        rootItemViewModel?.setRecursively(expanded: expanded)
    }
}
