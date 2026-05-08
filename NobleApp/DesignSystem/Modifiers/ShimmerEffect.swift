import SwiftUI

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = -1.4

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    Color.nobleYellow.opacity(0.55),
                                    .clear,
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 1.6)
                        .rotationEffect(.degrees(-22))
                        .offset(x: geometry.size.width * phase)
                        .blendMode(.plusLighter)
                }
            }
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                    phase = 1.4
                }
            }
    }
}
