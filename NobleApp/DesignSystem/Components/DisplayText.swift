import SwiftUI

struct DisplayText: View {
    let text: String
    let size: CGFloat
    let color: Color
    let lineHeight: CGFloat?

    init(
        _ text: String,
        size: CGFloat = 64,
        color: Color = .white,
        lineHeight: CGFloat? = nil
    ) {
        self.text = text
        self.size = size
        self.color = color
        self.lineHeight = lineHeight
    }

    var body: some View {
        Text(text)
            .font(.druk(size))
            .tracking(-1)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(color)
    }
}

#Preview("Stacked hero") {
    ZStack {
        Color.nobleOrange.ignoresSafeArea()
        VStack(alignment: .leading, spacing: -18) {
            DisplayText("YOUR", size: 96, color: .nobleBlack)
            DisplayText("COLLECTION", size: 96, color: .nobleBlack)
            DisplayText("IN 3D", size: 96, color: .nobleBlack)
        }
        .padding(.horizontal, Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
