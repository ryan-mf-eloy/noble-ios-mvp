import SwiftUI

struct ScriptText: View {
    let text: String
    let size: CGFloat
    let color: Color
    let rotation: Double

    init(
        _ text: String,
        size: CGFloat = 36,
        color: Color = .nobleOrange,
        rotation: Double = -2
    ) {
        self.text = text
        self.size = size
        self.color = color
        self.rotation = rotation
    }

    var body: some View {
        Text(text)
            .font(.caveat(size))
            .foregroundStyle(color)
            .rotationEffect(.degrees(rotation))
    }
}

#Preview {
    VStack(spacing: Spacing.l) {
        ScriptText("Buzz")
        ScriptText("Tipoff", size: 48, color: .nobleYellow, rotation: -3)
        ScriptText("Push", size: 56, color: .white, rotation: -4)
        ScriptText("rendering", size: 36, color: .nobleBlack, rotation: 0)
    }
    .padding(Spacing.xl)
    .background(Color.nobleBlack)
}
