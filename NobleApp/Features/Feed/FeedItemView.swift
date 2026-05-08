import SwiftUI
import UIKit

struct FeedItemView: View {
    let post: PostMock
    let onTap: () -> Void

    @State private var isLiked = false
    @State private var isBookmarked = false
    @State private var commentTrigger = false
    @State private var shareTrigger = false
    @State private var rotationPhase: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            header
            cardThumbnail
            engagementRow
            inlineComment
        }
    }

    // MARK: — Header

    private var header: some View {
        HStack(spacing: Spacing.s) {
            avatar

            Text(post.authorHandle)
                .font(.inter(14, weight: .black))
                .foregroundStyle(.white)

            Text("·")
                .foregroundStyle(Color.nobleMuted)

            Text(post.timeAgo)
                .font(.inter(13, weight: .regular))
                .foregroundStyle(Color.nobleMuted)

            Spacer()

            if post.isForSale, let price = post.listPrice {
                NoblePill(
                    "FOR SALE · $\(formatPrice(price))",
                    style: .filledYellow,
                    size: 9
                )
            }
        }
        .padding(.horizontal, Spacing.xl)
    }

    private var avatar: some View {
        Circle()
            .fill(Color(hex: post.authorAvatarColorHex))
            .frame(width: 32, height: 32)
            .overlay {
                Text(handleInitials)
                    .font(.inter(13, weight: .black))
                    .foregroundStyle(.white)
            }
    }

    // MARK: — Card thumbnail (SportsCardView showcase)

    private var cardThumbnail: some View {
        Button(action: onTap) {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: post.cardImageColorHex).opacity(0.18),
                        Color.nobleBlack,
                    ],
                    startPoint: .top, endPoint: .bottom
                )

                RadialGradient(
                    colors: [
                        Color(hex: post.cardImageColorHex).opacity(0.25),
                        .clear,
                    ],
                    center: .center, startRadius: 50, endRadius: 280
                )

                if let milestone = post.milestoneTreatment {
                    VStack {
                        HStack {
                            Spacer()
                            Text(milestone)
                                .font(.druk(140))
                                .foregroundStyle(.white.opacity(0.06))
                                .offset(x: 30, y: -10)
                        }
                        Spacer()
                    }
                }

                SportsCardView(card: postCard)
                    .frame(maxWidth: 260)
                    .rotation3DEffect(
                        .degrees(sin(rotationPhase) * 6),
                        axis: (x: 0.2, y: 1, z: 0),
                        perspective: 0.8
                    )
                    .padding(.vertical, Spacing.l)
                    .onAppear {
                        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                            rotationPhase = .pi * 2
                        }
                    }
            }
            .frame(height: 460)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Spacing.xl)
    }

    private var postCard: CardMock {
        MockDataProvider.cards.first { $0.id == post.cardID } ?? MockDataProvider.cards[0]
    }

    // MARK: — Engagement

    private var engagementRow: some View {
        HStack(spacing: Spacing.l) {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                isLiked.toggle()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isLiked ? "flame.fill" : "flame")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(isLiked ? Color.nobleOrange : .white)
                        .engagementBurst(.toggle, trigger: isLiked)
                    Text("\(post.likes + (isLiked ? 1 : 0))")
                        .font(.inter(13, weight: .bold))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText(value: Double(post.likes + (isLiked ? 1 : 0))))
                }
            }
            .buttonStyle(.plain)

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                commentTrigger.toggle()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .engagementBurst(.tap, trigger: commentTrigger)
                    Text("\(post.commentCount)")
                        .font(.inter(13, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                shareTrigger.toggle()
            } label: {
                Image(systemName: "paperplane")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .engagementBurst(.tap, trigger: shareTrigger)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                isBookmarked.toggle()
            } label: {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(isBookmarked ? Color.nobleOrange : .white)
                    .engagementBurst(.toggle, trigger: isBookmarked)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.xl)
    }

    @ViewBuilder
    private var inlineComment: some View {
        if let comment = post.topComment {
            Text(comment)
                .font(.inter(13, weight: .regular))
                .italic()
                .foregroundStyle(Color.nobleMuted)
                .padding(.horizontal, Spacing.xl)
        }
    }

    // MARK: — Helpers

    private var handleInitials: String {
        let stripped = post.authorHandle.replacingOccurrences(of: "@", with: "")
        return String(stripped.prefix(2).uppercased())
    }

    private func formatPrice(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US")
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSDecimalNumber) ?? "0"
    }
}

#Preview {
    FeedItemView(post: MockDataProvider.posts()[0]) {}
        .background(Color.nobleBlack)
}
