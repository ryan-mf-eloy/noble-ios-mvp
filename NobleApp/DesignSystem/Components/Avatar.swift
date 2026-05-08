import SwiftUI

struct Avatar: View {
    let size: CGFloat
    let hue: Double
    var ring: Color? = nil

    init(size: CGFloat = 28, hue: Double = 0, ring: Color? = nil) {
        self.size = size
        self.hue = hue
        self.ring = ring
    }

    var body: some View {
        Circle()
            .fill(
                AngularGradient(
                    colors: [
                        Color(hex: 0xFF4F1F),
                        Color(hex: 0xFFB800),
                        Color(hex: 0x00D26A),
                        Color(hex: 0x0066FF),
                        Color(hex: 0xFF4F1F)
                    ],
                    center: .center,
                    angle: .degrees(hue)
                )
            )
            .frame(width: size, height: size)
            .overlay(
                Circle().strokeBorder(ring ?? .clear, lineWidth: ring == nil ? 0 : 2)
            )
    }
}

#Preview {
    HStack(spacing: 12) {
        Avatar(size: 44, hue: 30)
        Avatar(size: 44, hue: 180)
        Avatar(size: 44, hue: 270, ring: .white)
    }
    .padding()
    .background(Color.nobleBlack)
}
