import SwiftUI

struct AuctionDetailView: View {
    let listing: AuctionListing
    let onOpenLive: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showBidDrawer = false
    @State private var bidAmount: Decimal = 25_000

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.nobleBlack.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    hero
                    metaBlock
                    currentBidBlock
                    bidHistorySection
                    recentlySoldSection
                    commentsSection
                    Spacer().frame(height: 120)
                }
            }
            .scrollIndicators(.hidden)

            stickyBidCTA
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showBidDrawer) {
            BidDrawerSheet(
                listing: listing,
                bidAmount: $bidAmount,
                onConfirm: { showBidDrawer = false }
            )
            .presentationDetents([.height(540)])
            .presentationBackground(Color.nobleBlack)
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: — Hero card

    private var hero: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0x1B1B1B), Color.nobleBlack],
                startPoint: .top, endPoint: .bottom
            )
            HalftonePattern(dotSize: 1.2, spacing: 6, color: Color.nobleOrange.opacity(0.08))

            VStack {
                heroToolbar
                    .padding(.horizontal, Spacing.l)

                SportsCardView(card: listing.card)
                    .frame(width: 220)
                    .padding(.top, 24)
                    .padding(.bottom, 30)

                watchingStrip
                    .padding(.horizontal, Spacing.l)
                    .padding(.bottom, 12)
            }
            .padding(.top, 8)
        }
    }

    private var heroToolbar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.nobleBlack)
                            .overlay(Circle().strokeBorder(Color.nobleBorder, lineWidth: 1.5))
                    )
            }
            .buttonStyle(.plain)
            Spacer()
            HStack(spacing: 8) {
                circleIcon("heart.fill", tint: .nobleOrange)
                circleIcon("square.and.arrow.up", tint: .white)
            }
        }
    }

    private func circleIcon(_ name: String, tint: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: 14, weight: .black))
            .foregroundStyle(tint)
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(Color.nobleBlack)
                    .overlay(Circle().strokeBorder(Color.nobleBorder, lineWidth: 1.5))
            )
    }

    private var watchingStrip: some View {
        HStack {
            HStack(spacing: -8) {
                ForEach([30.0, 180.0, 90.0, 270.0], id: \.self) { hue in
                    Avatar(size: 22, hue: hue, ring: .nobleBlack)
                }
            }
            Text("312 WATCHING NOW")
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundStyle(.white)
                .padding(.leading, 8)
            Spacer()
            CountdownChip(initialMs: 47 * 60_000 + 22_000)
        }
    }

    // MARK: — Title & tags

    private var metaBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Circle().fill(Color.white).frame(width: 6, height: 6)
                Text("LIVE AUCTION")
                    .font(.inter(10, weight: .black))
                    .tracking(1)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.nobleOrange))

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(listing.card.title.uppercased())
                    .font(.druk(28))
                    .foregroundStyle(.white)
                    .tracking(-0.5)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 8) {
                if let g = listing.card.grade { tagPill(g) }
                if listing.card.isRookie { tagPill("ROOKIE") }
                tagPill("POP \(listing.card.market.totalGraded.formatted(.number))", muted: true)
            }
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func tagPill(_ text: String, muted: Bool = false) -> some View {
        Text(text)
            .font(.inter(10, weight: .black))
            .tracking(1)
            .foregroundStyle(muted ? Color.nobleMuted : Color.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .strokeBorder(muted ? Color.nobleMuted : Color.white, lineWidth: 1.5)
            )
    }

    // MARK: — Current bid

    private var currentBidBlock: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("CURRENT BID")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.nobleMuted)
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(listing.price.nobleCurrency)
                        .font(.druk(34))
                        .foregroundStyle(.white)
                    Text("+$500")
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundStyle(Color.nobleSuccess)
                }
                HStack(spacing: 6) {
                    Avatar(size: 16, hue: 30)
                    Text("by")
                        .font(.inter(12)).foregroundStyle(Color.nobleMuted)
                    Text("@cardking")
                        .font(.inter(12, weight: .black))
                        .foregroundStyle(Color.nobleOrange)
                    Text("· \(listing.bids ?? 47) BIDS")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(Color.nobleMuted)
                }
            }
            Spacer()
            Sparkline(width: 70, height: 32, isUp: true)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.nobleSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.nobleBorder, lineWidth: 1.5)
                )
        )
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.l)
    }

    // MARK: — Bid history

    private var bidHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("BID HISTORY")
                    .font(.druk(16))
                    .foregroundStyle(.white)
                Spacer()
                Text("LIVE")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.nobleMuted)
            }

            VStack(spacing: 0) {
                ForEach(Array(AuctionMockProvider.bidHistory.enumerated()), id: \.element.id) { idx, bid in
                    bidRow(bid)
                    if idx < AuctionMockProvider.bidHistory.count - 1 {
                        Rectangle().fill(Color.nobleBorder).frame(height: 1)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.nobleSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.nobleBorder, lineWidth: 1.5)
                    )
            )
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, 24)
    }

    private func bidRow(_ b: AuctionBid) -> some View {
        HStack(spacing: 10) {
            Avatar(size: 28, hue: b.avatarHue)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("@\(b.user)")
                        .font(.inter(13, weight: .black))
                        .foregroundStyle(.white)
                    if b.isTop {
                        Text("HIGH")
                            .font(.inter(9, weight: .black))
                            .tracking(1)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.nobleOrange))
                    }
                }
                Text(b.timeAgo)
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.nobleMuted)
            }
            Spacer()
            Text(b.amount.nobleCurrency)
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundStyle(b.isTop ? Color.nobleOrange : Color.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(b.isTop ? Color.nobleOrange.opacity(0.08) : .clear)
    }

    // MARK: — Recently sold

    private var recentlySoldSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 4) {
                Text("RECENTLY SOLD")
                    .font(.druk(16))
                    .foregroundStyle(.white)
                Text("·")
                    .font(.druk(16))
                    .foregroundStyle(Color.nobleOrange)
                Text("COMPARABLES")
                    .font(.druk(16))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, Spacing.l)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(AuctionMockProvider.comparableSales) { s in
                        compCard(s)
                    }
                }
                .padding(.horizontal, Spacing.l)
            }
        }
        .padding(.top, 24)
    }

    private func compCard(_ s: ComparableSale) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(s.label)
                .font(.inter(11, weight: .black))
                .tracking(0.5)
                .foregroundStyle(Color.nobleMuted)
            HStack(alignment: .firstTextBaseline) {
                Text(s.amount.nobleCurrency)
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                    .foregroundStyle(.white)
                Spacer()
                Text(s.diffPercent)
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundStyle(s.isUp ? Color.nobleSuccess : Color.nobleLive)
            }
            Sparkline(width: 172, height: 24, isUp: s.isUp)
                .padding(.top, 2)
        }
        .padding(14)
        .frame(width: 200, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.nobleSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.nobleBorder, lineWidth: 1.5)
                )
        )
    }

    // MARK: — Comments

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(AuctionMockProvider.auctionComments.count) COMMENTS")
                .font(.druk(16))
                .foregroundStyle(.white)

            VStack(spacing: 0) {
                ForEach(Array(AuctionMockProvider.auctionComments.enumerated()), id: \.offset) { idx, c in
                    commentRow(user: c.user, hue: c.hue, text: c.text, fires: c.fires)
                    if idx < AuctionMockProvider.auctionComments.count - 1 {
                        Rectangle().fill(Color.nobleBorder).frame(height: 1)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, 24)
    }

    private func commentRow(user: String, hue: Double, text: String, fires: Int) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Avatar(size: 32, hue: hue)
            VStack(alignment: .leading, spacing: 2) {
                Text("@\(user)")
                    .font(.inter(12, weight: .black))
                    .foregroundStyle(.white)
                Text(text)
                    .font(.inter(13))
                    .foregroundStyle(.white)
                    .lineSpacing(2)
                HStack(spacing: 14) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11))
                        Text("\(fires)")
                            .font(.inter(11))
                    }
                    .foregroundStyle(Color.nobleMuted)
                    Text("Reply")
                        .font(.inter(11))
                        .foregroundStyle(Color.nobleMuted)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 10)
    }

    // MARK: — Sticky CTA

    private var stickyBidCTA: some View {
        VStack {
            Button {
                showBidDrawer = true
            } label: {
                HStack {
                    HStack(spacing: 10) {
                        Circle().fill(.white).frame(width: 8, height: 8)
                        Text("PLACE BID")
                            .font(.druk(16))
                            .tracking(-0.3)
                    }
                    Spacer()
                    Text("\(listing.price.nobleCurrency)+")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    Capsule().fill(Color.nobleOrange)
                        .shadow(color: Color.nobleOrange.opacity(0.45), radius: 16, y: 6)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            LinearGradient(
                colors: [Color.nobleBlack.opacity(0), Color.nobleBlack],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

// MARK: — Bid drawer

private struct BidDrawerSheet: View {
    let listing: AuctionListing
    @Binding var bidAmount: Decimal
    let onConfirm: () -> Void

    private let quickBids: [Decimal] = [25_000, 26_000, 28_000, 30_000]

    private var fee: Decimal {
        let raw = NSDecimalNumber(decimal: bidAmount).doubleValue * 0.12
        return Decimal(raw)
    }

    private var total: Decimal {
        let raw = NSDecimalNumber(decimal: bidAmount).doubleValue * 1.12
        return Decimal(raw)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("PLACE YOUR BID")
                .font(.druk(20))
                .foregroundStyle(.white)
                .padding(.top, 14)

            HStack {
                Text("MIN BID \(listing.price.nobleCurrency)")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.nobleMuted)
                Spacer()
                CountdownChip(initialMs: 47 * 60_000, urgent: true)
            }
            .padding(.top, 4)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("$")
                    .font(.druk(28))
                    .foregroundStyle(Color.nobleMuted)
                Text(formatPlain(bidAmount))
                    .font(.druk(36))
                    .foregroundStyle(.white)
                    .tracking(-1)
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.nobleSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.nobleOrange, lineWidth: 1.5)
                    )
            )
            .padding(.top, 16)

            HStack(spacing: 8) {
                ForEach(quickBids, id: \.self) { v in
                    Button {
                        bidAmount = v
                    } label: {
                        Text("$\(Int((v as NSDecimalNumber).doubleValue / 1000))K")
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                            .foregroundStyle(bidAmount == v ? Color.nobleBlack : Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(
                                Capsule().fill(bidAmount == v ? Color.white : .clear)
                                    .overlay(
                                        Capsule().strokeBorder(
                                            bidAmount == v ? Color.white : Color.nobleBorder,
                                            lineWidth: 1.5
                                        )
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 12)

            VStack(spacing: 0) {
                totalRow("Bid", bidAmount.nobleCurrency, highlight: false)
                totalRow("Buyer fee (12%)", fee.nobleCurrency, highlight: false)
                Rectangle().fill(Color.nobleBorder).frame(height: 1).padding(.vertical, 6)
                totalRow("Total", total.nobleCurrency, highlight: true)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.nobleSurface))
            .padding(.top, 16)

            Button {
                onConfirm()
            } label: {
                HStack {
                    Text("CONFIRM BID")
                        .font(.druk(15))
                        .tracking(0.6)
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 26)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(Capsule().fill(Color.nobleOrange))
            }
            .buttonStyle(.plain)
            .padding(.top, 14)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private func totalRow(_ label: String, _ value: String, highlight: Bool) -> some View {
        HStack {
            Text(label)
                .font(.inter(13, weight: highlight ? .black : .medium))
                .foregroundStyle(highlight ? Color.white : Color.nobleMuted)
            Spacer()
            Text(value)
                .font(.system(size: highlight ? 15 : 12, weight: .black, design: .monospaced))
                .foregroundStyle(highlight ? Color.nobleOrange : Color.white)
        }
        .padding(.vertical, 4)
    }

    private func formatPlain(_ d: Decimal) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f.string(from: NSDecimalNumber(decimal: d)) ?? "\(d)"
    }
}
