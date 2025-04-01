import SwiftUI
import SharedModels

struct QQuestionView: View {
    let item: QItem
    @State private var imageLoaded = false

    var body: some View {
        if item.questionType == .text, let content = item.content {
            Text(content)
                .font(.system(size: 14))
                .padding(.leading, 16)

        } else if item.questionType == .image, let imageURL = item.imageURL {
            let image = AsyncImageView(
                url: imageURL,
                onPhaseChange: { kind in
                    imageLoaded = (kind == .success)
                }
            )
            .frame(height: 120)
            .cornerRadius(8)
            .padding(.leading, 16)

            if imageLoaded {
                NavigationLink {
                    FullImageView(imageURL: imageURL, title: item.displayTitle)
                } label: {
                    image
                }
            } else {
                image
            }
        }
    }
}
