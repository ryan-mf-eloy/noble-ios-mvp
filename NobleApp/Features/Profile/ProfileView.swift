import SwiftUI

private enum ProfileTab: String, CaseIterable {
    case collection = "COLLECTION"
    case forSale    = "FOR SALE"
    case watchlist  = "WATCH LIST"
    case shared     = "SHARED"
}

private enum SportFilter: String, CaseIterable {
    case all = "ALL"
    case nba = "NBA"
    case nfl = "NFL"
    case mlb = "MLB"
    case nhl = "NHL"
    case pokemon = "POKÉMON"
}

struct ProfileView: View {
    @State private var activeTab: ProfileTab = .collection
    @State private var activeFilter: SportFilter = .all
    @State private var selectedCard: CardMock?
    @State private var showPortfolio = false

    private let allCards = MockDataProvider.cards

    private var filteredCards: [CardMock] {
        if activeFilter == .all { return allCards }
        return allCards.filter { card in
            switch activeFilter {
            case .nba:     card.sport == "NBA"
            case .nfl:     card.sport == "NFL"
            case .mlb:     card.sport == "MLB"
            case .nhl:     card.sport == "NHL"
            case .pokemon: card.sport == "Pokémon"
            case .all:     true
            }
        }
    }

    private let gridColumns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
    ]

    var body: some View {
        ZStack {
            Color.nobleBlack.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    coverHeader
                    statsRow
                    actionButtons
                    tabsRow
                    filterRow
                    grid
                }
            }
            .scrollIndicators(.hidden)
        }
        .sheet(item: $selectedCard) { card in
            NavigationStack { CardDetailView(card: card) }
                .presentationBackground(Color.nobleBlack)
        }
        .sheet(isPresented: $showPortfolio) {
            NavigationStack { PortfolioView() }
                .presentationBackground(Color.nobleBlack)
        }
    }

    // MARK: — Cover header

    private var coverHeader: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                Color.nobleOrange
                HalftonePattern(dotSize: 2, spacing: 14, color: .nobleBlack.opacity(0.10))
                AsteriskMark(size: 84, color: .nobleBlack)
                    .opacity(0.18)
                    .offset(x: 80, y: -20)
            }
            .frame(height: 180)
            .clipped()

            HStack(alignment: .bottom, spacing: Spacing.l) {
                avatar
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("Marcus Reed")
                            .font(.inter(20, weight: .black))
                            .foregroundStyle(.white)
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(Color.nobleVerified)
                    }
                    Text("@cardking")
                        .font(.inter(14, weight: .medium))
                        .foregroundStyle(Color.nobleMuted)
                }
                Spacer()
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, -32)
        }
        .padding(.bottom, 40)
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(Color.nobleBlack)
                .frame(width: 88, height: 88)

            Circle()
                .fill(Color.nobleOrange)
                .frame(width: 80, height: 80)
                .overlay {
                    Text("M")
                        .font(.druk(40))
                        .foregroundStyle(Color.nobleBlack)
                }
        }
    }

    // MARK: — Stats

    private var statsRow: some View {
        HStack(spacing: 0) {
            stat("8", "CARDS")
            divider
            stat("2.8K", "FOLLOWERS")
            divider
            stat("412", "FOLLOWING")
            divider
            stat("18.5K", "VIEWS")
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.vertical, Spacing.l)
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.druk(22))
                .foregroundStyle(.white)
            EyebrowText(label, color: .nobleMuted, size: 9)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.nobleOrange)
            .frame(width: 1, height: 32)
    }

    // MARK: — Action buttons

    private var actionButtons: some View {
        HStack(spacing: Spacing.s) {
            NobleButton("PORTFOLIO", style: .primaryOrange, fullWidth: true) {
                showPortfolio = true
            }
            NobleButton("SHARE", style: .secondaryOutlined, fullWidth: true) {}
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.bottom, Spacing.l)
    }

    // MARK: — Tabs

    private var tabsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(ProfileTab.allCases, id: \.self) { tab in
                    tabPill(for: tab)
                }
            }
            .padding(.horizontal, Spacing.xl)
        }
        .padding(.bottom, Spacing.m)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.nobleBorder).frame(height: 1)
        }
    }

    private func tabPill(for tab: ProfileTab) -> some View {
        Button { activeTab = tab } label: {
            VStack(spacing: 8) {
                Text(tab.rawValue)
                    .font(.inter(13, weight: .black))
                    .tracking(1.5)
                    .foregroundStyle(activeTab == tab ? .white : Color.nobleMuted)
                Rectangle()
                    .fill(activeTab == tab ? Color.nobleOrange : Color.clear)
                    .frame(height: 3)
            }
            .padding(.horizontal, Spacing.l)
        }
        .buttonStyle(.plain)
    }

    // MARK: — Filter pills

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.s) {
                ForEach(SportFilter.allCases, id: \.self) { filter in
                    filterPill(for: filter)
                }
            }
            .padding(.horizontal, Spacing.xl)
        }
        .padding(.vertical, Spacing.m)
    }

    private func filterPill(for filter: SportFilter) -> some View {
        let active = activeFilter == filter
        return Button { activeFilter = filter } label: {
            Text(filter.rawValue)
                .font(.inter(11, weight: .black))
                .tracking(1.5)
                .foregroundStyle(active ? Color.nobleBlack : .white)
                .padding(.horizontal, Spacing.m)
                .padding(.vertical, 6)
                .background(active ? Color.nobleOrange : Color.clear)
                .overlay(
                    Capsule()
                        .strokeBorder(active ? Color.nobleOrange : Color.nobleBorder, lineWidth: 1)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: — Grid

    private var grid: some View {
        LazyVGrid(columns: gridColumns, spacing: 4) {
            ForEach(filteredCards) { card in
                CardGridItem(card: card) {
                    selectedCard = card
                }
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.bottom, Spacing.hero)
    }
}

// MARK: — Card grid item (SportsCardView)

struct CardGridItem: View {
    let card: CardMock
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                SportsCardView(card: card)

                if let grade = card.grade {
                    NoblePill(grade, style: .filledOrange, size: 7)
                        .padding(6)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}
