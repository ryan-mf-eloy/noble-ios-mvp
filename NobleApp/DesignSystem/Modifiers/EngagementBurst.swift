import SwiftUI

struct EngagementBurst: ViewModifier {
    enum Style {
        case toggle
        case tap
    }

    let trigger: Bool
    let style: Style

    func body(content: Content) -> some View {
        content.phaseAnimator(
            [0.0, 1.0, 0.0],
            trigger: trigger,
            content: { view, value in
                applyMotion(to: view, value: value)
            },
            animation: { value in
                value == 1.0
                    ? .spring(response: 0.16, dampingFraction: 0.62)
                    : .spring(response: 0.30, dampingFraction: 0.85)
            }
        )
    }

    @ViewBuilder
    private func applyMotion<V: View>(to view: V, value: Double) -> some View {
        switch style {
        case .toggle:
            view
                .scaleEffect(1.0 + value * 0.18)
                .rotation3DEffect(
                    .degrees(value * 22),
                    axis: (x: 0, y: 1, z: 0.25),
                    perspective: 0.45
                )
        case .tap:
            view
                .scaleEffect(1.0 + value * 0.18)
                .rotation3DEffect(
                    .degrees(value * 18),
                    axis: (x: 1, y: 0.2, z: 0),
                    perspective: 0.5
                )
        }
    }
}

extension View {
    func engagementBurst(_ style: EngagementBurst.Style, trigger: Bool) -> some View {
        modifier(EngagementBurst(trigger: trigger, style: style))
    }
}

#Preview {
    struct Demo: View {
        @State private var likeCount = 0
        @State private var commentCount = 0
        @State private var shareCount = 0
        @State private var bookmarkCount = 0

        var body: some View {
            HStack(spacing: 32) {
                Button {
                    likeCount += 1
                } label: {
                    Image(systemName: likeCount.isMultiple(of: 2) ? "flame" : "flame.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(likeCount > 0 && !likeCount.isMultiple(of: 2)
                                         ? Color.nobleOrange : Color.white)
                        .engagementBurst(.toggle, trigger: !likeCount.isMultiple(of: 2))
                }

                Button {
                    commentCount += 1
                } label: {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                        .engagementBurst(.tap, trigger: commentCount.isMultiple(of: 2))
                }

                Button {
                    shareCount += 1
                } label: {
                    Image(systemName: "paperplane")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                        .engagementBurst(.tap, trigger: shareCount.isMultiple(of: 2))
                }

                Button {
                    bookmarkCount += 1
                } label: {
                    Image(systemName: bookmarkCount.isMultiple(of: 2) ? "bookmark" : "bookmark.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(bookmarkCount > 0 && !bookmarkCount.isMultiple(of: 2)
                                         ? Color.nobleOrange : Color.white)
                        .engagementBurst(.toggle, trigger: !bookmarkCount.isMultiple(of: 2))
                }
            }
            .padding(40)
            .background(Color.nobleBlack)
        }
    }
    return Demo().preferredColorScheme(.dark)
}
