import Foundation
import SwiftUI

enum CardArtStyle: String, Hashable {
    case chrome
    case prizm
    case optic
    case vintage
    case pokemonHolo
}

struct CardMock: Identifiable, Hashable {
    let id: UUID
    let title: String
    let year: Int
    let brand: String
    let playerName: String
    let cardNumber: String
    let position: String
    let team: String
    let teamColorPrimary: UInt32
    let teamColorSecondary: UInt32
    let grade: String?
    let sport: String
    let style: CardArtStyle
    let isRookie: Bool
    let estimatedValue: Decimal
    let trend30d: Double
    let imageColorHex: UInt32
    let hasSplat: Bool
    let ownerHandle: String
    let note: String?
    let imageAssetName: String?
    let capturedImageData: Data?
    let market: MarketData

    init(
        id: UUID = UUID(),
        title: String,
        year: Int,
        brand: String,
        playerName: String,
        cardNumber: String,
        position: String,
        team: String,
        teamColorPrimary: UInt32,
        teamColorSecondary: UInt32,
        grade: String? = nil,
        sport: String,
        style: CardArtStyle,
        isRookie: Bool = false,
        estimatedValue: Decimal,
        trend30d: Double = 0,
        hasSplat: Bool = true,
        ownerHandle: String,
        note: String? = nil,
        imageAssetName: String? = nil,
        capturedImageData: Data? = nil,
        market: MarketData
    ) {
        self.id = id
        self.title = title
        self.year = year
        self.brand = brand
        self.playerName = playerName
        self.cardNumber = cardNumber
        self.position = position
        self.team = team
        self.teamColorPrimary = teamColorPrimary
        self.teamColorSecondary = teamColorSecondary
        self.imageColorHex = teamColorPrimary
        self.grade = grade
        self.sport = sport
        self.style = style
        self.isRookie = isRookie
        self.estimatedValue = estimatedValue
        self.trend30d = trend30d
        self.hasSplat = hasSplat
        self.ownerHandle = ownerHandle
        self.note = note
        self.imageAssetName = imageAssetName
        self.capturedImageData = capturedImageData
        self.market = market
    }
}

struct PostMock: Identifiable, Hashable {
    let id: UUID
    let authorHandle: String
    let authorAvatarColorHex: UInt32
    let cardID: UUID
    let cardTitle: String
    let cardPlayerName: String
    let cardImageColorHex: UInt32
    let caption: String
    let isForSale: Bool
    let listPrice: Decimal?
    let likes: Int
    let commentCount: Int
    let topComment: String?
    let timeAgo: String
    let milestoneTreatment: String?
    let hasSplat: Bool

    init(
        id: UUID = UUID(),
        authorHandle: String,
        authorAvatarColorHex: UInt32,
        cardID: UUID,
        cardTitle: String,
        cardPlayerName: String,
        cardImageColorHex: UInt32,
        caption: String,
        isForSale: Bool = false,
        listPrice: Decimal? = nil,
        likes: Int = 0,
        commentCount: Int = 0,
        topComment: String? = nil,
        timeAgo: String = "2h",
        milestoneTreatment: String? = nil,
        hasSplat: Bool = true
    ) {
        self.id = id
        self.authorHandle = authorHandle
        self.authorAvatarColorHex = authorAvatarColorHex
        self.cardID = cardID
        self.cardTitle = cardTitle
        self.cardPlayerName = cardPlayerName
        self.cardImageColorHex = cardImageColorHex
        self.caption = caption
        self.isForSale = isForSale
        self.listPrice = listPrice
        self.likes = likes
        self.commentCount = commentCount
        self.topComment = topComment
        self.timeAgo = timeAgo
        self.milestoneTreatment = milestoneTreatment
        self.hasSplat = hasSplat
    }
}

struct CollectorMock: Identifiable, Hashable {
    let id = UUID()
    let handle: String
    let displayName: String
    let avatarColorHex: UInt32
    let isLive: Bool

    init(handle: String, displayName: String, avatarColorHex: UInt32, isLive: Bool = false) {
        self.handle = handle
        self.displayName = displayName
        self.avatarColorHex = avatarColorHex
        self.isLive = isLive
    }
}

struct CommentMock: Identifiable, Hashable {
    let id: UUID = UUID()
    let authorHandle: String
    let body: String
    let likes: Int
    let timeAgo: String
}

// MARK: — Market data (price history, pop report, recent sales)

struct PricePoint: Identifiable, Hashable {
    let id: UUID = UUID()
    let date: Date
    let price: Double
}

struct GradeCount: Identifiable, Hashable {
    let id: UUID = UUID()
    let grade: String
    let count: Int
}

struct SaleMock: Identifiable, Hashable {
    let id: UUID = UUID()
    let date: Date
    let grade: String
    let price: Double
    let priceChange: Double
}

struct MarketData: Hashable {
    let lastSale: Double
    let trend30d: Double
    let trend90d: Double
    let trend1y: Double
    let priceHistory: [PricePoint]
    let popReport: [GradeCount]
    let totalGraded: Int
    let recentSales: [SaleMock]
    let monthlyVolume: Int
    let highSale: Double
    let lowSale: Double
}
