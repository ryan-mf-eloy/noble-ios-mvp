import SwiftUI

struct EyebrowText: View {
    let text: String
    let color: Color
    let size: CGFloat

    init(_ text: String, color: Color = .nobleOrange, size: CGFloat = 11) {
        self.text = text
        self.color = color
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(.inter(size, weight: .bold))
            .tracking(2)
            .textCase(.uppercase)
            .foregroundStyle(color)
    }
}

#Preview {
    VStack(spacing: 12) {
        EyebrowText("1986 FLEER")
        EyebrowText("FLAT SURFACE · EVEN LIGHTING", color: .nobleBlack)
        EyebrowText("LIVE NOW", color: .nobleLive)
        EyebrowText("FOR SALE · $4,200", color: .nobleBlack)
    }
    .padding(Spacing.xl)
    .background(Color.nobleSurface)
}
