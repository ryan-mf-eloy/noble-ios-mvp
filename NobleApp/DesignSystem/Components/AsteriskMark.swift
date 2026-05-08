import SwiftUI

struct AsteriskMark: View {
    let size: CGFloat
    let color: Color

    init(size: CGFloat = 24, color: Color = .nobleOrange) {
        self.size = size
        self.color = color
    }

    var body: some View {
        AsteriskShape()
            .fill(color)
            .frame(width: size, height: size)
    }
}

struct AsteriskShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.32
        let points = 8

        var path = Path()
        let totalVertices = points * 2

        for i in 0..<totalVertices {
            let isOuter = i.isMultiple(of: 2)
            let radius = isOuter ? outerRadius : innerRadius
            let angle = (Double(i) * .pi / Double(points)) - .pi / 2
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack(spacing: Spacing.xl) {
        HStack(spacing: Spacing.l) {
            AsteriskMark(size: 16, color: .nobleOrange)
            AsteriskMark(size: 24, color: .nobleOrange)
            AsteriskMark(size: 48, color: .nobleOrange)
            AsteriskMark(size: 96, color: .nobleOrange)
        }
        HStack(spacing: Spacing.l) {
            AsteriskMark(size: 48, color: .nobleBlack)
            AsteriskMark(size: 48, color: .nobleYellow)
            AsteriskMark(size: 48, color: .white)
        }
    }
    .padding(Spacing.xl)
    .background(Color.nobleSurface)
}
