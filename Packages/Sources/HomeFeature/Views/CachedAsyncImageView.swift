import SwiftUI
import DataFeature

struct CachedAsyncImageView: View {
    let url: URL
    var onPhaseChange: ((AsyncImagePhase.Kind) -> Void)? = nil

    @State private var currentKind: AsyncImagePhase.Kind = .empty
    @State private var cachedImage: Image?

    var body: some View {
        Group {
            if let cachedImage {
                cachedImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                AsyncImage(url: url, scale: 1.0) { phase in
                    let kind = phase.kind

                    ZStack {
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

                        if kind == .success {
                            Task {
                                await ImageCache.shared.cacheImageData(from: url, width: 120, height: 120)
                            }
                        }
                    }
                }
            }
        }
        .task {
            if cachedImage == nil {
                cachedImage = await ImageCache.shared.platformImage(for: url, width: 120, height: 120)
            }
        }
    }
}
