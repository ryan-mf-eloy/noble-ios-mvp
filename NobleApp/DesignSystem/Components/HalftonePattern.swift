import SwiftUI

struct HalftonePattern: View {
    let dotSize: CGFloat
    let spacing: CGFloat
    let color: Color

    init(
        dotSize: CGFloat = 2,
        spacing: CGFloat = 12,
        color: Color = .nobleBlack
    ) {
        self.dotSize = dotSize
        self.spacing = spacing
        self.color = color
    }

    var body: some View {
        Canvas { context, size in
            let cols = Int(size.width / spacing) + 2
            let rows = Int(size.height / spacing) + 2
            for r in 0..<rows {
                for c in 0..<cols {
                    let x = CGFloat(c) * spacing
                    let y = CGFloat(r) * spacing
                    let dotRect = CGRect(
                        x: x - dotSize / 2,
                        y: y - dotSize / 2,
                        width: dotSize,
                        height: dotSize
                    )
                    context.fill(Path(ellipseIn: dotRect), with: .color(color))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview("On orange") {
    ZStack {
        Color.nobleOrange.ignoresSafeArea()
        HalftonePattern(
            dotSize: 2,
            spacing: 14,
            color: .nobleBlack.opacity(0.12)
        )
        .ignoresSafeArea()
        Text("HALFTONE OVERLAY")
            .font(.druk(48))
            .foregroundStyle(Color.nobleBlack)
    }
}

#Preview("On black") {
    ZStack {
        Color.nobleBlack.ignoresSafeArea()
        HalftonePattern(
            dotSize: 1.5,
            spacing: 10,
            color: .nobleOrange.opacity(0.15)
        )
        .ignoresSafeArea()
        Text("DARK HALFTONE")
            .font(.druk(48))
            .foregroundStyle(.white)
    }
}
