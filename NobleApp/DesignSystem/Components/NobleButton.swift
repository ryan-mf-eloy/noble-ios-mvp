import SwiftUI
import UIKit

struct NobleButton: View {
    enum Style {
        case primaryOrange
        case primaryBlack
        case secondaryOutlined
    }

    let title: String
    let style: Style
    let fullWidth: Bool
    let action: () -> Void

    init(
        _ title: String,
        style: Style = .primaryOrange,
        fullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.fullWidth = fullWidth
        self.action = action
    }

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        } label: {
            Text(title)
                .font(.inter(16, weight: .black))
                .tracking(0.5)
                .textCase(.uppercase)
                .foregroundStyle(foreground)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .padding(.vertical, Spacing.l)
                .padding(.horizontal, Spacing.xl)
                .background(background)
                .overlay(border)
                .clipShape(RoundedRectangle(cornerRadius: Radius.sharp))
        }
        .buttonStyle(NoblePressedStyle())
    }

    private var foreground: Color {
        switch style {
        case .primaryOrange:     .nobleBlack
        case .primaryBlack:      .white
        case .secondaryOutlined: .nobleOrange
        }
    }

    private var background: Color {
        switch style {
        case .primaryOrange:     .nobleOrange
        case .primaryBlack:      .nobleBlack
        case .secondaryOutlined: .clear
        }
    }

    @ViewBuilder
    private var border: some View {
        if style == .secondaryOutlined {
            RoundedRectangle(cornerRadius: Radius.sharp)
                .strokeBorder(Color.nobleOrange, lineWidth: 2)
        }
    }
}

private struct NoblePressedStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        NobleButton("GET STARTED →", style: .primaryOrange, fullWidth: true) {}
        NobleButton("GET STARTED →", style: .primaryBlack, fullWidth: true) {}
        NobleButton("CONTINUE WITH GOOGLE", style: .secondaryOutlined, fullWidth: true) {}
        HStack(spacing: 12) {
            NobleButton("EDIT", style: .secondaryOutlined) {}
            NobleButton("LIST FOR SALE", style: .primaryOrange, fullWidth: true) {}
        }
    }
    .padding()
    .background(Color.nobleSurface)
}
