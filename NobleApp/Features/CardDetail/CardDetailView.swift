import SwiftUI

struct CardDetailView: View {
    let card: CardMock
    @Environment(\.dismiss) private var dismiss
    @State private var showHint = true
    @State private var scrollPosition: ScrollPosition = .init()
    @State private var isInteractingWithSplat = false
    @State private var isLiked = false
    @State private var isBookmarked = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                splatViewer
                engagementBar
                metadata
            }
        }
        .scrollIndicators(.hidden)
        .scrollPosition($scrollPosition)
        .scrollDisabled(isInteractingWithSplat)
        .contentMargins(.bottom, 96, for: .scrollContent)
        .scrollEdgeEffectStyle(.soft, for: [.top, .bottom])
        .background(Color.nobleBlack.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            headerBar
        }
        .overlay(alignment: .bottom) {
            actionBar
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            scrollPosition.scrollTo(edge: .top)
        }
        .task {
            if ProcessInfo.processInfo.arguments.contains("--scrolled-card") {
                try? await Task.sleep(for: .milliseconds(800))
                withAnimation(.smooth(duration: 1.2)) {
                    scrollPosition.scrollTo(y: 280)
                }
            }
            if ProcessInfo.processInfo.arguments.contains("--scrolled-market") {
                try? await Task.sleep(for: .milliseconds(800))
                withAnimation(.smooth(duration: 1.4)) {
                    scrollPosition.scrollTo(y: 1100)
                }
            }
            try? await Task.sleep(for: .seconds(3))
            withAnimation(.easeOut(duration: 0.4)) { showHint = false }
        }
    }

    // MARK: — Header (top, glass background, scroll edge soft fade applied to scroll)

    private var headerBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .black))
            }
            .buttonStyle(.glass)
            .tint(.white)

            Spacer()

            Button {} label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 17, weight: .black))
            }
            .buttonStyle(.glass)
            .tint(.white)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.vertical, Spacing.s)
    }

    // MARK: — Splat viewer

    private var splatViewer: some View {
        ZStack {
            RadialGradient(
                colors: [Color.nobleYellow.opacity(0.22), .clear],
                center: .center, startRadius: 90, endRadius: 420
            )

            SplatViewerView(card: card)

            if showHint {
                VStack {
                    Spacer()
                    EyebrowText("DRAG · PINCH · DOUBLE-TAP", color: .white, size: 10)
                        .padding(.horizontal, Spacing.m)
                        .padding(.vertical, 6)
                        .glassEffect(.regular.tint(.nobleOrange), in: .capsule)
                        .padding(.bottom, Spacing.xl)
                        .transition(.opacity)
                }
            }
        }
        .containerRelativeFrame(.vertical) { length, _ in length * 0.95 }
        .visualEffect { content, geometry in
            let frame = geometry.frame(in: .scrollView(axis: .vertical))
            let scrollDistance = max(0, -frame.minY)
            let progress = min(1.0, scrollDistance / 280.0)
            let scale = 1.0 - progress * 0.50
            let lift = -progress * 60
            let opacity = 1.0 - progress * 0.35
            return content
                .scaleEffect(scale, anchor: .top)
                .offset(y: lift)
                .opacity(opacity)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isInteractingWithSplat { isInteractingWithSplat = true }
                }
                .onEnded { _ in
                    isInteractingWithSplat = false
                }
        )
    }

    // MARK: — Engagement bar

    private var engagementBar: some View {
        HStack(spacing: 0) {
            engagementItem(
                icon: isLiked ? "flame.fill" : "flame",
                count: derivedLikes + (isLiked ? 1 : 0),
                tintActive: isLiked,
                burstTrigger: isLiked,
                burstStyle: .toggle
            ) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                isLiked.toggle()
            }

            engagementItem(
                icon: "bubble.left",
                count: derivedComments,
                burstTrigger: commentTapTrigger,
                burstStyle: .tap
            ) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                commentTapTrigger.toggle()
            }

            engagementItem(icon: "eye", count: derivedViews, interactive: false) {}

            Spacer(minLength: 0)

            iconAction(
                icon: "paperplane",
                tintActive: false,
                burstTrigger: shareTapTrigger,
                burstStyle: .tap
            ) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                shareTapTrigger.toggle()
            }
            .padding(.trailing, Spacing.l)

            iconAction(
                icon: isBookmarked ? "bookmark.fill" : "bookmark",
                tintActive: isBookmarked,
                burstTrigger: isBookmarked,
                burstStyle: .toggle
            ) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                isBookmarked.toggle()
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.s)
        .padding(.bottom, Spacing.l)
    }

    @State private var commentTapTrigger = false
    @State private var shareTapTrigger = false

    private func engagementItem(
        icon: String,
        count: Int,
        tintActive: Bool = false,
        interactive: Bool = true,
        burstTrigger: Bool = false,
        burstStyle: EngagementBurst.Style = .toggle,
        action: @escaping () -> Void = {}
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(tintActive ? Color.nobleOrange : Color.white.opacity(0.9))
                    .engagementBurst(burstStyle, trigger: burstTrigger)
                Text(formatCompact(count))
                    .font(.mono(13))
                    .foregroundStyle(Color.white.opacity(0.9))
                    .contentTransition(.numericText(value: Double(count)))
            }
            .padding(.trailing, Spacing.xl)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(interactive)
    }

    private func iconAction(
        icon: String,
        tintActive: Bool,
        burstTrigger: Bool = false,
        burstStyle: EngagementBurst.Style = .toggle,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(tintActive ? Color.nobleOrange : Color.white.opacity(0.9))
                .engagementBurst(burstStyle, trigger: burstTrigger)
        }
        .buttonStyle(.plain)
    }

    private var derivedLikes: Int {
        max(40, Int(card.market.lastSale / 100))
    }
    private var derivedComments: Int {
        max(3, Int(card.market.lastSale / 1_500))
    }
    private var derivedViews: Int {
        max(120, Int(card.market.lastSale * 0.4))
    }

    private func formatCompact(_ n: Int) -> String {
        if n >= 1_000_000 { return String(format: "%.1fM", Double(n) / 1_000_000) }
        if n >= 10_000 { return String(format: "%.1fK", Double(n) / 1_000) }
        if n >= 1_000 {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.locale = Locale(identifier: "en_US")
            return f.string(from: NSNumber(value: n)) ?? "\(n)"
        }
        return "\(n)"
    }

    // MARK: — Metadata

    private var metadata: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            EyebrowText("\(String(card.year)) \(card.brand.uppercased())", color: .nobleOrange)

            playerNameStack

            pillsRow

            stats.padding(.vertical, Spacing.m)

            MarketSection(card: card)
                .padding(.bottom, Spacing.s)

            if let note = card.note {
                story(note: note)
            }

            comments
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.xl)
    }

    private var playerNameStack: some View {
        let words = card.playerName.split(separator: " ").map { String($0).uppercased() }
        return VStack(alignment: .leading, spacing: -10) {
            ForEach(Array(words.enumerated()), id: \.offset) { _, word in
                DisplayText(word, size: 64)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var pillsRow: some View {
        HStack(spacing: Spacing.s) {
            if let grade = card.grade {
                NoblePill(grade, style: .filledOrange)
            }
            NoblePill("ROOKIE", style: .filledYellow)
            NoblePill("MINT", style: .outlined)
        }
    }

    private var stats: some View {
        StatBlock(items: [
            StatItem("EST. VALUE", "$\(formatPrice(card.estimatedValue))"),
            StatItem(
                "30-DAY",
                formatTrend(card.trend30d),
                color: card.trend30d >= 0 ? .nobleSuccess : .nobleLive
            ),
            StatItem("GRADE", card.grade ?? "—"),
        ])
    }

    private func story(note: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            EyebrowText("YOUR STORY", color: .nobleMuted)
            Text(note)
                .font(.inter(15, weight: .regular))
                .foregroundStyle(.white)
                .lineSpacing(4)
                .padding(Spacing.l)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.nobleSurface)
                .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        }
    }

    private var comments: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            EyebrowText("COMMENTS", color: .nobleMuted)
            ForEach(MockDataProvider.comments(for: card.id).prefix(3)) { comment in
                HStack(alignment: .top, spacing: Spacing.s) {
                    Text(comment.authorHandle)
                        .font(.inter(14, weight: .black))
                        .foregroundStyle(Color.nobleOrange)
                    Text(comment.body)
                        .font(.inter(14, weight: .regular))
                        .foregroundStyle(.white)
                    Spacer()
                }
            }
            Text("View all comments")
                .font(.inter(13, weight: .medium))
                .foregroundStyle(Color.nobleMuted)
                .underline()
        }
        .padding(.top, Spacing.s)
    }

    // MARK: — Floating Liquid Glass action bar

    private var actionBar: some View {
        GlassEffectContainer(spacing: Spacing.s) {
            HStack(spacing: Spacing.s) {
                Button {} label: {
                    Text("PLACE BID")
                        .font(.inter(14, weight: .black))
                        .tracking(1.5)
                        .textCase(.uppercase)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .tint(.nobleOrange)
                .controlSize(.large)

                Button {} label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 17, weight: .black))
                }
                .buttonStyle(.glass)
                .tint(.nobleOrange)
                .controlSize(.large)
            }
        }
        .padding(.horizontal, Spacing.l)
        .padding(.bottom, Spacing.s)
    }

    // MARK: — Formatters

    private func formatPrice(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US")
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSDecimalNumber) ?? "0"
    }

    private func formatTrend(_ value: Double) -> String {
        let arrow = value >= 0 ? "▲" : "▼"
        return "\(arrow) \(String(format: "%.1f", abs(value) * 100))%"
    }
}

#Preview {
    NavigationStack {
        CardDetailView(card: MockDataProvider.cards[0])
    }
}
