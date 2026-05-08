import SwiftUI

struct Sparkline: View {
    let width: CGFloat
    let height: CGFloat
    let isUp: Bool
    var filled: Bool = false

    private var seed: [Double] {
        isUp
            ? [25, 22, 24, 18, 20, 14, 16, 10, 12, 6, 8, 2]
            : [4, 8, 6, 10, 8, 12, 10, 15, 12, 18, 16, 22]
    }

    private var color: Color { isUp ? .nobleSuccess : .nobleLive }

    var body: some View {
        GeometryReader { _ in
            let points: [CGPoint] = seed.enumerated().map { i, y in
                let x = CGFloat(i) / CGFloat(seed.count - 1) * width
                let yScaled = CGFloat(y) * (height / 30)
                return CGPoint(x: x, y: yScaled)
            }

            ZStack {
                if filled {
                    Path { p in
                        guard let first = points.first else { return }
                        p.move(to: first)
                        for pt in points.dropFirst() { p.addLine(to: pt) }
                        p.addLine(to: CGPoint(x: width, y: height))
                        p.addLine(to: CGPoint(x: 0, y: height))
                        p.closeSubpath()
                    }
                    .fill(color.opacity(0.12))
                }

                Path { p in
                    guard let first = points.first else { return }
                    p.move(to: first)
                    for pt in points.dropFirst() { p.addLine(to: pt) }
                }
                .stroke(color, style: StrokeStyle(lineWidth: filled ? 2.5 : 1.6, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: width, height: height)
    }
}

#Preview {
    VStack(spacing: 16) {
        Sparkline(width: 120, height: 40, isUp: true)
        Sparkline(width: 120, height: 40, isUp: false)
        Sparkline(width: 200, height: 60, isUp: true, filled: true)
    }
    .padding()
    .background(Color.nobleBlack)
}
