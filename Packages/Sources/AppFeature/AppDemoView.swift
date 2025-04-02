import SwiftUI
import DataFeature
import HomeFeature
import BetaSettingsFeature

public struct AppDemoView: View {

    @State private var dataService: DataService

    public init() {
        let persistenceManager = PersistenceManager()
        let service = DataService(persistenceManager: persistenceManager)
        _dataService = State(initialValue: service)
    }

    public var body: some View {
        TabView {
            ContentView(dataService: dataService)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            BetaSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
