import SwiftUI
import DataFeature

private struct RootItemSection: View {
    let root: QItemViewModel?

    var body: some View {
        if let root = root {
            QItemView(viewModel: root, depth: 0)
        }
    }
}

private struct LoadedStateView: View {
    let root: QItemViewModel?
    let showCachedData: Bool

    var body: some View {
        ZStack(alignment: .top) {
            List {
                RootItemSection(root: root)
            }

            if showCachedData {
                CachedDataView()
            }
        }
    }
}

private struct ContentBodyView: View {
    let viewModel: ContentViewModel
    @Binding var showCachedData: Bool

    var body: some View {
        Group {
            switch viewModel.loadState {
            case .idle, .loading:
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded:
                LoadedStateView(root: viewModel.rootItemViewModel, showCachedData: showCachedData)

            case .error(let error):
                ErrorView(error: error) {
                    Task { await viewModel.loadData() }
                }
            }
        }
    }
}

@MainActor
public struct ContentView: View {
    @State private var viewModel: ContentViewModel
    @State private var showCachedData = false
    @State private var navigationTitle: String

    public init(dataService: DataService) {
        _viewModel = State(wrappedValue: ContentViewModel(dataService: dataService))
        #if os(iOS)
        _navigationTitle = State(initialValue: "iOS Challenge")
        #else
        _navigationTitle = State(initialValue: "macOS Challenge")
        #endif
    }

    private var baseTitle: String {
        #if os(iOS)
        "iOS Challenge"
        #else
        "macOS Challenge"
        #endif
    }

    private var toolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .navigationBarTrailing
        #else
        .automatic
        #endif
    }

    public var body: some View {
        NavigationStack {
            ContentBodyView(viewModel: viewModel, showCachedData: $showCachedData)
                .navigationTitle(navigationTitle)
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItemGroup(placement: toolbarPlacement) {
                        Button {
                            viewModel.setAllExpanded(false)
                        } label: {
                            Label("Collapse All", systemImage: "arrow.down.right.and.arrow.up.left")
                        }

                        Button {
                            viewModel.setAllExpanded(true)
                        } label: {
                            Label("Expand All", systemImage: "arrow.up.left.and.arrow.down.right")
                        }
                    }
                }
        }
        .task {
            await viewModel.loadData()
        }
        .onChange(of: viewModel.loadState.kind) { _, newState in
            if case .loaded = newState {
                Task {
                    let isUsingCached = viewModel.isUsingCachedData
                    if isUsingCached {
                        withAnimation {
                            showCachedData = true
                            navigationTitle = baseTitle
                        }

                        try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)

                        withAnimation {
                            showCachedData = false
                            navigationTitle = "\(baseTitle) 💾"
                        }
                    } else {
                        withAnimation {
                            showCachedData = false
                            navigationTitle = baseTitle
                        }
                    }
                }
            }
        }
    }
}
