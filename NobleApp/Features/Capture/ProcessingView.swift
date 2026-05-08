import SwiftUI
import UIKit

struct DiagonalCutShape: Shape {
    let cut: CGFloat

    init(cut: CGFloat = 24) { self.cut = cut }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: cut, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cut))
        path.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: cut))
        path.closeSubpath()
        return path
    }
}

struct ProcessingView: View {
    let card: CardMock
    let onComplete: () -> Void

    @State private var progress: Double = 0

    var body: some View {
        ZStack {
            Color.nobleOrange.ignoresSafeArea()
            HalftonePattern(dotSize: 2, spacing: 14, color: .nobleBlack.opacity(0.10))
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                ScriptText("rendering", size: 32, color: .nobleBlack, rotation: -2)

                cardThumbnail

                VStack(alignment: .leading, spacing: -10) {
                    DisplayText("GENERATING", size: 56, color: .nobleBlack)
                    DisplayText("YOUR 3D", size: 56, color: .nobleBlack)
                }

                EyebrowText("≈30 SECONDS · WE'LL PING YOU", color: .nobleBlack, size: 11)

                progressBar
                    .padding(.horizontal, Spacing.xxl)

                Spacer()

                Button(action: onComplete) {
                    Text("Continue browsing →")
                        .font(.inter(15, weight: .bold))
                        .underline()
                        .foregroundStyle(Color.nobleBlack)
                }
                .padding(.bottom, Spacing.l)
            }
            .padding(.horizontal, Spacing.xl)
        }
        .task {
            await runMockProcessing()
        }
    }

    // MARK: — Components

    @ViewBuilder
    private var cardThumbnail: some View {
        if let data = card.capturedImageData,
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 180, height: 252)
                .clipShape(DiagonalCutShape(cut: 18))
                .overlay(
                    DiagonalCutShape(cut: 18)
                        .stroke(Color.nobleBlack.opacity(0.15), lineWidth: 1)
                )
                .modifier(ShimmerEffect())
        } else {
            ZStack {
                DiagonalCutShape(cut: 18)
                    .fill(Color(hex: card.imageColorHex))

                VStack(spacing: 6) {
                    Text(card.playerName.uppercased())
                        .font(.druk(20))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.s)
                    Text(card.cardNumber)
                        .font(.inter(11, weight: .black))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding()
            }
            .frame(width: 180, height: 252)
            .modifier(ShimmerEffect())
        }
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.nobleBlack.opacity(0.15)).frame(height: 4)
                Capsule().fill(Color.nobleBlack).frame(width: geometry.size.width * progress, height: 4)
            }
        }
        .frame(height: 4)
    }

    private func runMockProcessing() async {
        for step in 0...30 {
            try? await Task.sleep(for: .milliseconds(100))
            withAnimation(.linear(duration: 0.1)) {
                progress = Double(step) / 30.0
            }
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        onComplete()
    }
}

#Preview {
    ProcessingView(card: MockDataProvider.cards[0]) {}
}
