import SwiftUI

public struct BetaSettingsView: View {
    @State private var selection: LoadSimulation = BetaSettings.shared.loadSimulation

    public init() {}

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Simulated Load State").font(.caption).foregroundColor(.secondary)) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Load State")
                            .font(.headline)
                            .padding(.bottom, 4)

                        Divider() // ⬅️ line under the title

                        ForEach(LoadSimulation.allCases, id: \.self) { value in
                            Button(action: {
                                selection = value
                            }) {
                                HStack {
                                    Text(value.description)
                                    Spacer()
                                    if value == selection {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.accentColor)
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .padding(.vertical, 8)

                            if value != LoadSimulation.allCases.last {
                                Divider()
                            }
                        }
                    }
                    .padding(.vertical, 4)
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
