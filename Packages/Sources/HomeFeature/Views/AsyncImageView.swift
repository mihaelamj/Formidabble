import SwiftUI

public extension AsyncImagePhase {
    enum Kind {
        case empty
        case success
        case failure
    }

    var kind: Kind {
        switch self {
        case .empty: return .empty
        case .success: return .success
        case .failure: return .failure
        @unknown default: return .empty
        }
    }
}

struct AsyncImageView: View {
    let url: URL
    var onPhaseChange: ((AsyncImagePhase.Kind) -> Void)?

    @State private var currentKind: AsyncImagePhase.Kind = .empty

    var body: some View {
        AsyncImage(url: url, scale: 1.0) { phase in
            let kind = phase.kind

            // 🔍 Log phase changes
            if kind != currentKind {
                print("📸 AsyncImageView - URL: \(url)")
                switch kind {
                case .empty:
                    print("🕓 Phase: .empty (loading)")
                case .success:
                    print("✅ Phase: .success")
                case .failure:
                    print("❌ Phase: .failure")
                }
            }

            return ZStack {
                ProgressView()
                    .opacity(kind == .empty ? 1 : 0)

                phase.image?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(kind == .success ? 1 : 0)

                Color.clear
                    .aspectRatio(contentMode: .fit)
                    .opacity(phase.image == nil ? 1 : 0)

                Image(systemName: "photo.artframe")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.secondary)
                    .padding(24)
                    .opacity(kind == .failure ? 1 : 0)
            }
            .onChange(of: kind) {
                currentKind = kind
                onPhaseChange?(kind)
            }
        }
    }
}
