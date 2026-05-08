import Foundation
import SwiftUI

// MARK: — Auction listings

enum ListingType { case auction, buyNow }

struct AuctionListing: Identifiable, Hashable {
    let id = UUID()
    let card: CardMock
    let type: ListingType
    let price: Decimal
    let bids: Int?
    let endsLabel: String?
    let endsInMs: Int?
    let watching: Int
    let isHot: Bool
    let isUrgent: Bool
}

// MARK: — Bid history

struct AuctionBid: Identifiable, Hashable {
    let id = UUID()
    let user: String
    let amount: Decimal
    let timeAgo: String
    let avatarHue: Double
    let isTop: Bool
}

// MARK: — Comparable sales (recently sold)

struct ComparableSale: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let amount: Decimal
    let diffPercent: String
    let isUp: Bool
}

// MARK: — Activity feed

enum ActivityKind: String { case bid, watch, sale, react, follow, comment, milestone }

struct ActivityEvent: Identifiable, Hashable {
    let id = UUID()
    let kind: ActivityKind
    let user: String
    let avatarHue: Double
    let text: String
    let meta: String
    let accent: ActivityAccent
    let timeAgo: String
}

enum ActivityAccent { case orange, yellow, success, live, white
    var color: Color {
        switch self {
        case .orange: .nobleOrange
        case .yellow: .nobleYellow
        case .success: .nobleSuccess
        case .live: .nobleLive
        case .white: .white
        }
    }
}

// MARK: — Portfolio holdings

struct PortfolioHolding: Identifiable, Hashable {
    let id = UUID()
    let card: CardMock
    let cost: Decimal
    let currentValue: Decimal
    let diffPercent: String
    let isUp: Bool
}

// MARK: — Live drop chat

struct LiveChatMessage: Identifiable, Hashable {
    let id = UUID()
    let user: String
    let avatarHue: Double
    let text: String
    let isFire: Bool
}

// MARK: — Provider

enum AuctionMockProvider {

    static var marketListings: [AuctionListing] {
        let cards = MockDataProvider.cards
        return [
            AuctionListing(
                card: cards[0],
                type: .auction, price: 24_500, bids: 47,
                endsLabel: "2h 14m", endsInMs: 2 * 3_600_000 + 14 * 60_000,
                watching: 312, isHot: true, isUrgent: false),
            AuctionListing(
                card: cards[2],
                type: .buyNow, price: 8_900, bids: nil,
                endsLabel: nil, endsInMs: nil,
                watching: 89, isHot: false, isUrgent: false),
            AuctionListing(
                card: cards[9],
                type: .auction, price: 1_250, bids: 12,
                endsLabel: "47m", endsInMs: 47 * 60_000,
                watching: 64, isHot: false, isUrgent: true),
            AuctionListing(
                card: cards[3],
                type: .buyNow, price: 3_400, bids: nil,
                endsLabel: nil, endsInMs: nil,
                watching: 22, isHot: false, isUrgent: false),
            AuctionListing(
                card: cards[4],
                type: .auction, price: 6_800, bids: 8,
                endsLabel: "6h", endsInMs: 6 * 3_600_000,
                watching: 41, isHot: false, isUrgent: false),
            AuctionListing(
                card: cards[14],
                type: .buyNow, price: 12_000, bids: nil,
                endsLabel: nil, endsInMs: nil,
                watching: 173, isHot: false, isUrgent: false),
        ]
    }

    static let bidHistory: [AuctionBid] = [
        AuctionBid(user: "cardking", amount: 24_500, timeAgo: "12s ago", avatarHue: 30,  isTop: true),
        AuctionBid(user: "waxkid87", amount: 24_000, timeAgo: "2m ago",  avatarHue: 180, isTop: false),
        AuctionBid(user: "psahunt",  amount: 23_250, timeAgo: "4m ago",  avatarHue: 210, isTop: false),
        AuctionBid(user: "cardking", amount: 22_750, timeAgo: "8m ago",  avatarHue: 30,  isTop: false),
        AuctionBid(user: "rookie99", amount: 22_000, timeAgo: "15m ago", avatarHue: 90,  isTop: false),
        AuctionBid(user: "mintguy",  amount: 21_500, timeAgo: "24m ago", avatarHue: 270, isTop: false),
    ]

    static let comparableSales: [ComparableSale] = [
        ComparableSale(label: "PSA 9 · Sold last week",   amount: 23_800, diffPercent: "+2.9%", isUp: true),
        ComparableSale(label: "PSA 9 · Goldin · Mar",     amount: 22_400, diffPercent: "+9.4%", isUp: true),
        ComparableSale(label: "PSA 8 · Mar 12",            amount: 14_200, diffPercent: "+1.2%", isUp: true),
    ]

    static let auctionComments: [(user: String, hue: Double, text: String, fires: Int)] = [
        ("jules.psa", 180, "centering on this is a fortune. send it.", 24),
        ("mintguy",   270, "pop report says 142 graded 10s — last 10 went for 92k.", 11),
        ("rookie99",   90, "whoever wins this please don't hide it 🙏", 8),
    ]

    static let activity: [ActivityEvent] = [
        ActivityEvent(kind: .bid,       user: "cardking",  avatarHue: 30,
            text: "placed a bid on M. Jordan #57", meta: "$24,500", accent: .orange,  timeAgo: "12s"),
        ActivityEvent(kind: .watch,     user: "foilbar",   avatarHue: 210,
            text: "is watching A. Wing #14", meta: "+1 watcher", accent: .yellow,    timeAgo: "1m"),
        ActivityEvent(kind: .sale,      user: "mintguy",   avatarHue: 270,
            text: "SOLD R. Johnson #08", meta: "$3,400", accent: .success,            timeAgo: "4m"),
        ActivityEvent(kind: .react,     user: "jules.psa", avatarHue: 180,
            text: "reacted 🔥 to your card", meta: "M. Jordan", accent: .orange,      timeAgo: "8m"),
        ActivityEvent(kind: .follow,    user: "rookie99",  avatarHue: 90,
            text: "started following you", meta: "FOLLOW BACK", accent: .white,       timeAgo: "12m"),
        ActivityEvent(kind: .comment,   user: "psahunt",   avatarHue: 350,
            text: "\"absolutely clean centering 👌\"", meta: "on M. Jordan", accent: .white, timeAgo: "20m"),
        ActivityEvent(kind: .bid,       user: "waxkid87",  avatarHue: 140,
            text: "outbid you on Charizard", meta: "$8,900", accent: .live,           timeAgo: "32m"),
        ActivityEvent(kind: .milestone, user: "noble",     avatarHue: 0,
            text: "Your collection hit $38K — top 3% this week", meta: "🏆", accent: .yellow, timeAgo: "1h"),
    ]

    static var holdings: [PortfolioHolding] {
        let cards = MockDataProvider.cards
        return [
            PortfolioHolding(card: cards[0],  cost: 18_200, currentValue: 24_500, diffPercent: "+34.6%", isUp: true),
            PortfolioHolding(card: cards[2],  cost: 11_400, currentValue:  8_900, diffPercent: "-21.9%", isUp: false),
            PortfolioHolding(card: cards[9],  cost:    420, currentValue:  1_250, diffPercent: "+197%",  isUp: true),
            PortfolioHolding(card: cards[3],  cost:  2_800, currentValue:  3_400, diffPercent: "+21.4%", isUp: true),
        ]
    }

    static var topMovers: [PortfolioHolding] {
        let cards = MockDataProvider.cards
        return [
            PortfolioHolding(card: cards[9],  cost: 0, currentValue:  1_250, diffPercent: "+24.3%", isUp: true),
            PortfolioHolding(card: cards[0],  cost: 0, currentValue: 24_500, diffPercent: "+12.4%", isUp: true),
            PortfolioHolding(card: cards[2],  cost: 0, currentValue:  8_900, diffPercent:  "-8.2%", isUp: false),
            PortfolioHolding(card: cards[3],  cost: 0, currentValue:  3_400, diffPercent:  "+5.1%", isUp: true),
        ]
    }

    static let liveChat: [LiveChatMessage] = [
        LiveChatMessage(user: "rookie99",  avatarHue: 90,  text: "i'm in for 250 lfg", isFire: false),
        LiveChatMessage(user: "cardking",  avatarHue: 30,  text: "🔥🔥🔥",              isFire: true),
        LiveChatMessage(user: "jules.psa", avatarHue: 180, text: "centering looks A+ on this", isFire: false),
        LiveChatMessage(user: "mintguy",   avatarHue: 270, text: "BID",                isFire: false),
        LiveChatMessage(user: "foilbar",   avatarHue: 210, text: "last one i went home with cost me 1.4k worth it", isFire: false),
        LiveChatMessage(user: "graderx",   avatarHue: 350, text: "who's the seller?",  isFire: false),
    ]

    static var portfolioChart: [Double] {
        let n = 56
        var arr: [Double] = []
        for i in 0..<n {
            let base = 30_000.0 + Double(i) * 300
            let wave = sin(Double(i) * 0.4) * 1_200 + cos(Double(i) * 0.18) * 2_400
            let drift = (Double(i % 7) - 2.5) * 380
            arr.append(max(20_000, base + wave + drift))
        }
        if !arr.isEmpty { arr[arr.count - 1] = 38_050 }
        return arr
    }
}

// MARK: — Decimal currency formatting helper

extension Decimal {
    var nobleCurrency: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "en_US")
        f.maximumFractionDigits = 0
        return f.string(from: NSDecimalNumber(decimal: self)) ?? "$\(self)"
    }
}
