import SwiftUI
import DataFeature

@MainActor
public struct ContentView: View {
    @State private var viewModel: ContentViewModel

    public init(dataService: DataService) {
        _viewModel = State(wrappedValue: ContentViewModel(dataService: dataService))
    }

    // Platform-specific toolbar placement
    private var toolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        return .navigationBarTrailing
        #else
        return .automatic
        #endif
    }

    public var body: some View {
        NavigationStack {
            Group {
                switch viewModel.loadState {
                case .idle, .loading:
                    ProgressView("Loading...")
                case .loaded:
                    List {
                        ForEach(viewModel.itemViewModels) { itemVM in
                            QItemView(viewModel: itemVM, depth: 0)
                        }
                    }
                case .error(let error):
                    VStack {
                        Text("Failed to load content")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(.red)
                        Button("Retry") {
                            Task { await viewModel.loadData() }
                        }
                        .buttonStyle(.bordered)
                        .padding()
                    }
                }
            }
            .navigationTitle("iOS Challenge")
            .toolbar {
                ToolbarItemGroup(placement: toolbarPlacement) {
                    Button("Collapse All") { viewModel.setAllExpanded(false) }
                    Button("Expand All") { viewModel.setAllExpanded(true) }
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}
