import SwiftUI

@ViewBuilder
func optionalTitle(_ title: String, font: Font = .headline, leading: CGFloat = 0) -> some View {
    Text(title)
        .font(font)
        .padding(.leading, leading)
        .foregroundColor(title.isEmpty ? .clear : nil)
}
