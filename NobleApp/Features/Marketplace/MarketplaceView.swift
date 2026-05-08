import SwiftUI

private enum MarketFilter: String, CaseIterable, Hashable {
    case all      = "ALL"
    case auction  = "AUCTIONS"
    case buyNow   = "BUY NOW"
    case ending   = "ENDING SOON"
    case watch    = "WATCHLIST"
}

struct MarketplaceView: View {
    @State private var filter: MarketFilter = .all
    @State private var saved: Set<UUID> = []
    @State private var pickedAuction: AuctionListing?
    @State private var showLive = false

    private let listings = AuctionMockProvider.marketListings

    private var filteredListings: [AuctionListing] {
        switch filter {
        case .all:     listings
        case .auction: listings.filter { $0.type == .auction }
        case .buyNow:  listings.filter { $0.type == .buyNow }
        case .ending:  listings.filter { $0.isUrgent || ($0.endsInMs ?? .max) < 3 * 3_600_000 }
        case .watch:   listings.filter { saved.contains($0.id) }
        }
    }

    var body: some View {
        ZStack {
            Color.nobleBlack.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, Spacing.l)
                        .padding(.top, 8)

                    liveDropBanner
                        .padding(.horizontal, Spacing.l)
                        .padding(.top, Spacing.s)
                        .padding(.bottom, Spacing.m)

                    filterTabs
                        .padding(.bottom, Spacing.m)

                    grid
                        .padding(.horizontal, Spacing.l)
                        .padding(.bottom, 120)
                }
            }
            .scrollIndicators(.hidden)
        }
        .sheet(item: $pickedAuction) { listing in
            NavigationStack {
                AuctionDetailView(listing: listing,
                                  onOpenLive: { showLive = true })
            }
            .presentationBackground(Color.nobleBlack)
        }
        .fullScreenCover(isPresented: $showLive) {
            LiveDropView(onClose: { showLive = false })
        }
    }

    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                AsteriskMark(size: 18, color: .nobleOrange)
                Text("MARKET")
                    .font(.druk(22))
                    .foregroundStyle(.white)
            }
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "bell")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().strokeBorder(Color.nobleBorder, lineWidth: 1.5))
            }
        }
    }

    private var liveDropBanner: some View {
        Button {
            showLive = true
        } label: {
            ZStack {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.nobleBlack)
                            .frame(width: 44, height: 44)
                            .overlay(Circle().strokeBorder(Color.white, lineWidth: 2))
                        Circle()
                            .fill(Color.nobleLive)
                            .frame(width: 10, height: 10)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("LIVE NOW · WAX SESSIONS")
                            .font(.druk(16))
                            .foregroundStyle(Color.nobleBlack)
                            .tracking(-0.3)
                        Text("847 watching · 3 cards left")
                            .font(.inter(11, weight: .black))
                            .foregroundStyle(Color.nobleBlack.opacity(0.85))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(Color.nobleBlack)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(
                ZStack {
                    Color.nobleOrange
                    HalftonePattern(dotSize: 2, spacing: 4, color: .nobleBlack.opacity(0.18))
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(MarketFilter.allCases, id: \.self) { f in
                    Button {
                        filter = f
                    } label: {
                        Text(f.rawValue)
                            .font(.inter(11, weight: .black))
                            .tracking(1)
                            .foregroundStyle(filter == f ? Color.nobleBlack : Color.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(filter == f ? Color.white : Color.nobleSurface)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.l)
        }
    }

    private let cols = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    private var grid: some View {
        LazyVGrid(columns: cols, spacing: 10) {
            ForEach(filteredListings) { listing in
                MarketCardCell(
                    listing: listing,
                    isSaved: saved.contains(listing.id),
                    onToggleSave: {
                        if saved.contains(listing.id) { saved.remove(listing.id) }
                        else { saved.insert(listing.id) }
                    },
                    onTap: { pickedAuction = listing }
                )
            }
        }
    }
}

// MARK: — Card cell

private struct MarketCardCell: View {
    let listing: AuctionListing
    let isSaved: Bool
    let onToggleSave: () -> Void
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    SportsCardView(card: listing.card)
                        .padding(10)

                    typeBadge
                        .padding(14)

                    Button(action: onToggleSave) {
                        Image(systemName: isSaved ? "heart.fill" : "heart")
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(isSaved ? Color.nobleOrange : Color.white)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle().fill(Color.nobleBlack)
                                    .overlay(Circle().strokeBorder(Color.nobleBorder, lineWidth: 1))
                            )
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .topTrailing)
                    .padding(14)

                    if listing.isHot {
                        VStack {
                            HStack {
                                Spacer()
                                hotBadge
                            }
                            Spacer()
                        }
                    }
                }

                meta
            }
            .background(Color.nobleSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.nobleBorder, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var typeBadge: some View {
        switch listing.type {
        case .auction:
            HStack(spacing: 5) {
                if listing.isUrgent {
                    Circle().fill(.white).frame(width: 5, height: 5)
                }
                Text("BID · \(listing.endsLabel ?? "")")
                    .font(.inter(9, weight: .black))
                    .tracking(1)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(listing.isUrgent ? Color.nobleLive : Color.nobleBlack)
                    .overlay(Capsule().strokeBorder(Color.white, lineWidth: 1))
            )
        case .buyNow:
            Text("BUY NOW")
                .font(.inter(9, weight: .black))
                .tracking(1)
                .foregroundStyle(Color.nobleBlack)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.nobleYellow))
        }
    }

    private var hotBadge: some View {
        Text("🔥 HOT")
            .font(.system(size: 9, weight: .black, design: .monospaced))
            .tracking(1)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                UnevenRoundedRectangle(
                    cornerRadii: .init(topLeading: 0, bottomLeading: 12, bottomTrailing: 0, topTrailing: 0),
                    style: .continuous
                ).fill(Color.nobleOrange)
            )
    }

    private var meta: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(listing.card.playerName.uppercased())
                .font(.druk(13))
                .tracking(-0.3)
                .foregroundStyle(.white)
                .lineLimit(1)
                .truncationMode(.tail)
            HStack(alignment: .firstTextBaseline) {
                Text(listing.price.nobleCurrency)
                    .font(.system(size: 14, weight: .black, design: .monospaced))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                Spacer()
                if let bids = listing.bids {
                    Text("\(bids) BIDS")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(Color.nobleMuted)
                } else {
                    HStack(spacing: 3) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 9))
                        Text("\(listing.watching)")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                    }
                    .foregroundStyle(Color.nobleMuted)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
        .padding(.top, 0)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    MarketplaceView()
}
