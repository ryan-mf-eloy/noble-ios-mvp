import SwiftUI

private enum ActivityFilter: String, CaseIterable, Hashable {
    case all = "ALL", mine = "MINE", watching = "WATCHING"
}

struct ActivityView: View {
    let onAddCard: () -> Void
    var onOpenPortfolio: () -> Void = {}

    @State private var filter: ActivityFilter = .all

    private let events = AuctionMockProvider.activity

    var body: some View {
        ZStack {
            Color.nobleBlack.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, Spacing.l)
                        .padding(.top, 8)
                    filterTabs
                        .padding(.horizontal, Spacing.l)
                        .padding(.top, Spacing.s)
                        .padding(.bottom, Spacing.m)
                    milestoneHero
                        .padding(.horizontal, Spacing.l)
                        .padding(.bottom, 14)
                    list
                        .padding(.horizontal, Spacing.l)
                        .padding(.bottom, 100)
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: — Header

    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                AsteriskMark(size: 18, color: .nobleOrange)
                Text("ACTIVITY")
                    .font(.druk(22))
                    .foregroundStyle(.white)
            }
            Spacer()
            Button(action: onAddCard) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().strokeBorder(Color.nobleBorder, lineWidth: 1.5))
            }
            .buttonStyle(.plain)
        }
    }

    private var filterTabs: some View {
        HStack(spacing: 6) {
            ForEach(ActivityFilter.allCases, id: \.self) { f in
                Button {
                    filter = f
                } label: {
                    Text(f.rawValue)
                        .font(.inter(11, weight: .black))
                        .tracking(1)
                        .foregroundStyle(filter == f ? Color.nobleBlack : Color.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(filter == f ? Color.white : Color.nobleSurface))
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }

    // MARK: — Milestone hero

    private var milestoneHero: some View {
        ZStack {
            Color.nobleYellow
            HalftonePattern(dotSize: 1.4, spacing: 5, color: .nobleBlack.opacity(0.18))

            VStack(alignment: .leading, spacing: 6) {
                Text("NEW MILESTONE · TOP 3% THIS WEEK")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.nobleBlack)
                Text("$38K HIT")
                    .font(.druk(28))
                    .foregroundStyle(Color.nobleBlack)
                Text("Your portfolio just crossed a new high.")
                    .font(.inter(13, weight: .black))
                    .foregroundStyle(Color.nobleBlack)
                Button {
                    onOpenPortfolio()
                } label: {
                    HStack(spacing: 4) {
                        Text("VIEW PORTFOLIO")
                        Image(systemName: "arrow.right")
                    }
                    .font(.inter(11, weight: .black))
                    .tracking(1)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .frame(height: 38)
                    .background(Capsule().fill(Color.nobleBlack))
                }
                .buttonStyle(.plain)
                .padding(.top, 6)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // MARK: — Activity list

    private var list: some View {
        VStack(spacing: 0) {
            ForEach(events) { e in
                row(e)
                Rectangle().fill(Color.nobleBorder).frame(height: 1)
            }
        }
    }

    private func row(_ e: ActivityEvent) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Avatar(size: 36, hue: e.avatarHue)
            VStack(alignment: .leading, spacing: 4) {
                (
                    Text("@\(e.user) ")
                        .foregroundStyle(e.accent.color)
                        .font(.inter(13, weight: .black))
                    +
                    Text(e.text)
                        .foregroundStyle(.white)
                        .font(.inter(13))
                )
                .lineSpacing(2)

                HStack(spacing: 8) {
                    Text("\(e.timeAgo) ago")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(Color.nobleMuted)
                    Circle().fill(Color.nobleMuted).frame(width: 3, height: 3)
                    Text(e.meta)
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(e.accent.color)
                }
            }
            Spacer()
            typeMarker(e)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 4)
    }

    private func typeMarker(_ e: ActivityEvent) -> some View {
        Text(symbolFor(e.kind))
            .font(.system(size: 12, weight: .black, design: .monospaced))
            .foregroundStyle(e.accent.color)
            .frame(width: 28, height: 28)
            .background(
                Circle()
                    .fill(e.accent.color.opacity(0.15))
                    .overlay(Circle().strokeBorder(e.accent.color, lineWidth: 1))
            )
    }

    private func symbolFor(_ k: ActivityKind) -> String {
        switch k {
        case .bid:       "$"
        case .watch:     "👁"
        case .sale:      "✓"
        case .react:     "♥"
        case .follow:    "+"
        case .comment:   "\""
        case .milestone: "★"
        }
    }
}

#Preview {
    ActivityView(onAddCard: {})
}
