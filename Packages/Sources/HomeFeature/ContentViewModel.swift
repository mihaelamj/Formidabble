import SwiftUI

@Observable
@MainActor
final class ContentViewModel {
    
    enum LoadState {
        case idle, loading, loaded, error(Error)
    }
    
    private let dataService: DataService
    
    var itemViewModels: [QItemViewModel] = []
    var loadState: LoadState = .idle

    init(dataService: DataService) {
        self.dataService = dataService
    }
    
    func loadData() async {
        loadState = .loading
        
        do {
            let items = try await dataService.fetchData()
            itemViewModels = items.map { QItemViewModel(item: $0) }
            loadState = .loaded
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
