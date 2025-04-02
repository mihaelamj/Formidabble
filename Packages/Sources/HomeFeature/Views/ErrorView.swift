import SwiftUI

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
                .padding()

            Text("Unable to Load Content")
                .font(.title)
                .fontWeight(.bold)

            Text(errorMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 10) {
                Text("What you can do:")
                    .font(.headline)

                HStack(alignment: .top) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                    Text("Tap the Retry button to attempt loading the content again")
                }

                HStack(alignment: .top) {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.blue)
                    Text("Check your internet connection")
                }

                HStack(alignment: .top) {
                    Image(systemName: "arrow.right.arrow.left")
                        .foregroundColor(.blue)
                    Text("Close and reopen the app")
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))

            .cornerRadius(10)
            .shadow(radius: 2)
            .padding(.horizontal)

            Button(action: retryAction) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .padding()
                .frame(minWidth: 150)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
    }

    private var errorMessage: String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "You're not connected to the internet. Please check your connection and try again."
            case .timedOut:
                return "The request timed out. The server might be busy or your connection is slow."
            case .cannotFindHost, .cannotConnectToHost:
                return "Unable to connect to the server. Please check your internet connection."
            default:
                return "An error occurred while loading content: \(error.localizedDescription)"
            }
        } else {
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}
