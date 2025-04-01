import SwiftUI
import DataFeature
import HomeFeature

public struct AppView: View {
    
    @State private var dataService: DataService

    public init() {
        let persistenceManager = PersistenceManager()
        _dataService = State(initialValue: DataService(persistenceManager: persistenceManager))
    }
    
    public var body: some View {
        ContentView(dataService: dataService)
    }
}
