import SwiftUI

struct NoblePill: View {
    enum Style {
        case filledOrange
        case filledYellow
        case filledGreen
        case filledLive
        case outlined
    }

    let text: String
    let style: Style
    let size: CGFloat

    init(_ text: String, style: Style = .filledOrange, size: CGFloat = 11) {
        self.text = text
        self.style = style
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(.inter(size, weight: .black))
            .tracking(1.5)
            .textCase(.uppercase)
            .foregroundStyle(foreground)
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, 4)
            .background(background)
            .overlay(border)
            .clipShape(Capsule())
    }

    private var foreground: Color {
        switch style {
        case .filledOrange, .filledYellow, .filledGreen: .nobleBlack
        case .filledLive, .outlined: .white
        }
    }

    private var background: Color {
        switch style {
        case .filledOrange: .nobleOrange
        case .filledYellow: .nobleYellow
        case .filledGreen:  .nobleSuccess
        case .filledLive:   .nobleLive
        case .outlined:     .clear
        }
    }

    @ViewBuilder
    private var border: some View {
        if style == .outlined {
            Capsule().strokeBorder(Color.white, lineWidth: 1)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        NoblePill("PSA 9", style: .filledOrange)
        NoblePill("ROOKIE", style: .filledYellow)
        NoblePill("FOR SALE · $4,200", style: .filledYellow)
        NoblePill("LIVE NOW", style: .filledLive)
        NoblePill("MINT", style: .outlined)
        NoblePill("✓ LIGHTING", style: .filledGreen, size: 9)
    }
    .padding(Spacing.xl)
    .background(Color.nobleBlack)
}
