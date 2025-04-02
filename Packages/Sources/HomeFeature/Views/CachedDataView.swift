import SwiftUI

struct CachedDataView: View {
    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")
            Text("Offline Mode - Using Cached Data")
                .font(.caption)
        }
        .padding(8)
        .background(Color.secondary.opacity(0.9))
        .cornerRadius(8)
        .shadow(radius: 2)
        .padding(.top, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
