import SwiftUI

struct FullImageView: View {
    let imageURL: URL
    let title: String
    
    var body: some View {
        VStack {
            optionalTitle(title, font: .headline)
                .padding()
            
            AsyncImage(url: imageURL) { phase in
                ZStack {
                    // Loading indicator - always present
                    ProgressView()
                        .opacity(phase.kind == .empty ? 1 : 0)
                    
                    // Success case - image
                    phase.image?
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    // Error view - always present
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                        Text("Failed to load image")
                    }
                    .opacity(phase.kind == .failure ? 1 : 0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Image Detail")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
