import SwiftUI

public struct BetaSettingsView: View {
    @State private var selection: LoadSimulation = BetaSettings.shared.loadSimulation

    public init() {}

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Simulated Load State")) {
                    Picker("Load State", selection: $selection) {
                        ForEach(LoadSimulation.allCases, id: \.self) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section {
                    Button("Save & Restart") {
                        BetaSettings.shared.loadSimulation = selection
                        exit(0)
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Beta Settings")
        }
    }
}
