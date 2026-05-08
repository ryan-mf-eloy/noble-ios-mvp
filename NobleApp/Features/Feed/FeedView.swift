import SwiftUI
import UIKit

struct FeedView: View {
    var onAddCard: () -> Void = {}

    @State private var showCardDetail: CardMock?
    @State private var posts: [PostMock] = MockDataProvider.posts()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.xxl) {
                VStack(spacing: Spacing.l) {
                    topBar
                    StoriesRail()
                }

                ForEach(posts) { post in
                    FeedItemView(post: post) {
                        showCardDetail = card(for: post)
                    }
                }
            }
            .padding(.bottom, Spacing.xxxl)
        }
        .scrollIndicators(.hidden)
        .scrollEdgeEffectStyle(.soft, for: .top)
        .background(Color.nobleBlack.ignoresSafeArea())
        .sheet(item: $showCardDetail) { card in
            NavigationStack {
                CardDetailView(card: card)
            }
            .presentationBackground(Color.nobleBlack)
        }
    }

    private var topBar: some View {
        HStack {
            AsteriskMark(size: 28, color: .nobleOrange)
            Spacer()
            DisplayText("NOBLE", size: 24)
            Spacer()
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onAddCard()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Color.nobleBlack)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.nobleOrange))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Capture card")
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.vertical, Spacing.xs)
    }

    private func card(for post: PostMock) -> CardMock {
        MockDataProvider.cards.first { $0.id == post.cardID } ?? MockDataProvider.cards[0]
    }
}

#Preview {
    FeedView()
}
