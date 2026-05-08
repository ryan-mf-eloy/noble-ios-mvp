import Foundation

private extension Int {
    func clamped(_ range: ClosedRange<Int>) -> Int { Swift.min(range.upperBound, Swift.max(range.lowerBound, self)) }
}

enum MockDataProvider {
    // MARK: — Cards (19 high-value cards across NBA, NFL, MLB, NHL, Pokémon, Yu-Gi-Oh, MTG, Soccer)
    static let cards: [CardMock] = [
        CardMock(
            title: "1986 Fleer Michael Jordan #57",
            year: 1986, brand: "Fleer",
            playerName: "Michael Jordan", cardNumber: "57",
            position: "G", team: "Chicago Bulls",
            teamColorPrimary: 0xCE1141, teamColorSecondary: 0x000000,
            grade: "PSA 9", sport: "NBA", style: .vintage,
            isRookie: true,
            estimatedValue: 28_500, trend30d: 0.124,
            ownerHandle: "@cardking",
            note: "Found this at a flea market in Chicago in '02. Graded last spring — best money I ever spent.",
            imageAssetName: "card_jordan_fleer_1986",
            market: makeMarket(currentValue: 28_500, trend30d: 0.124, grade: "PSA 9", isVintage: true)
        ),
        CardMock(
            title: "2018 Donruss Optic Luka Dončić #177",
            year: 2018, brand: "Donruss Optic",
            playerName: "Luka Dončić", cardNumber: "177",
            position: "G", team: "Dallas Mavericks",
            teamColorPrimary: 0x00538C, teamColorSecondary: 0xB8C4CA,
            grade: "PSA 10", sport: "NBA", style: .optic,
            isRookie: true,
            estimatedValue: 4_200, trend30d: 0.082,
            ownerHandle: "@hoopsdaily",
            imageAssetName: "card_luka_optic_2018",
            market: makeMarket(currentValue: 4_200, trend30d: 0.082, grade: "PSA 10", isVintage: false)
        ),
        CardMock(
            title: "1999 Pokémon Charizard 1st Ed #4",
            year: 1999, brand: "Pokémon",
            playerName: "Charizard", cardNumber: "4",
            position: "Stage 2", team: "Base Set 1st Ed",
            teamColorPrimary: 0xFF6F00, teamColorSecondary: 0xFFB000,
            grade: "BGS 9.5", sport: "Pokémon", style: .pokemonHolo,
            isRookie: false,
            estimatedValue: 95_000, trend30d: 0.218,
            ownerHandle: "@pokegrails",
            imageAssetName: "card_charizard_pokemon_1999",
            market: makeMarket(currentValue: 95_000, trend30d: 0.218, grade: "BGS 9.5", isVintage: true)
        ),
        CardMock(
            title: "2018 Topps Chrome Shohei Ohtani #150",
            year: 2018, brand: "Topps Chrome",
            playerName: "Shohei Ohtani", cardNumber: "150",
            position: "P/DH", team: "LA Angels",
            teamColorPrimary: 0xBA0021, teamColorSecondary: 0x003263,
            grade: "PSA 10", sport: "MLB", style: .chrome,
            isRookie: true,
            estimatedValue: 1_850, trend30d: -0.031,
            ownerHandle: "@diamondkings",
            imageAssetName: "card_ohtani_topps_2018",
            market: makeMarket(currentValue: 1_850, trend30d: -0.031, grade: "PSA 10", isVintage: false)
        ),
        CardMock(
            title: "2017 Panini Prizm Patrick Mahomes #269",
            year: 2017, brand: "Panini Prizm",
            playerName: "Patrick Mahomes", cardNumber: "269",
            position: "QB", team: "Kansas City Chiefs",
            teamColorPrimary: 0xE31837, teamColorSecondary: 0xFFB81C,
            grade: "PSA 10", sport: "NFL", style: .prizm,
            isRookie: true,
            estimatedValue: 6_800, trend30d: 0.054,
            ownerHandle: "@gridironpulls",
            imageAssetName: "card_mahomes_prizm_2017",
            market: makeMarket(currentValue: 6_800, trend30d: 0.054, grade: "PSA 10", isVintage: false)
        ),
        CardMock(
            title: "2019 Topps Chrome Vladimir Guerrero Jr.",
            year: 2019, brand: "Topps Chrome",
            playerName: "Vladimir Guerrero", cardNumber: "203",
            position: "1B", team: "Toronto Blue Jays",
            teamColorPrimary: 0x134A8E, teamColorSecondary: 0x1D2D5C,
            grade: "PSA 10", sport: "MLB", style: .chrome,
            isRookie: true,
            estimatedValue: 320, trend30d: 0.018,
            ownerHandle: "@vintageonly",
            imageAssetName: "card_vladdy_topps_2019",
            market: makeMarket(currentValue: 320, trend30d: 0.018, grade: "PSA 10", isVintage: false)
        ),
        CardMock(
            title: "1979 O-Pee-Chee Wayne Gretzky RC",
            year: 1979, brand: "O-Pee-Chee",
            playerName: "Wayne Gretzky", cardNumber: "18",
            position: "C", team: "Edmonton Oilers",
            teamColorPrimary: 0x041E42, teamColorSecondary: 0xFF4C00,
            grade: "PSA 8", sport: "NHL", style: .vintage,
            isRookie: true,
            estimatedValue: 42_000, trend30d: 0.063,
            ownerHandle: "@cardking",
            imageAssetName: "card_gretzky_opc_1979",
            market: makeMarket(currentValue: 42_000, trend30d: 0.063, grade: "PSA 8", isVintage: true)
        ),
        CardMock(
            title: "2003 Topps Chrome LeBron James RC",
            year: 2003, brand: "Topps Chrome",
            playerName: "LeBron James", cardNumber: "111",
            position: "F", team: "Cleveland Cavaliers",
            teamColorPrimary: 0x860038, teamColorSecondary: 0xFDBB30,
            grade: "PSA 10", sport: "NBA", style: .chrome,
            isRookie: true,
            estimatedValue: 18_500, trend30d: 0.094,
            ownerHandle: "@hoopsdaily",
            imageAssetName: "card_lebron_topps_2003",
            market: makeMarket(currentValue: 18_500, trend30d: 0.094, grade: "PSA 10", isVintage: false)
        ),
        CardMock(
            title: "1996 Topps Chrome Kobe Bryant RC #138",
            year: 1996, brand: "Topps Chrome",
            playerName: "Kobe Bryant", cardNumber: "138",
            position: "G", team: "Los Angeles Lakers",
            teamColorPrimary: 0x552583, teamColorSecondary: 0xFDB927,
            grade: "PSA 9", sport: "NBA", style: .chrome,
            isRookie: true,
            estimatedValue: 4_400, trend30d: 0.087,
            ownerHandle: "@cardking",
            note: "The card that built the modern hobby. Mamba forever.",
            imageAssetName: "card_kobe_topps_1996",
            market: makeMarket(currentValue: 4_400, trend30d: 0.087, grade: "PSA 9", isVintage: false)
        ),
        CardMock(
            title: "2023 Prizm Silver Wembanyama RC #136",
            year: 2023, brand: "Panini Prizm",
            playerName: "Victor Wembanyama", cardNumber: "136",
            position: "C", team: "San Antonio Spurs",
            teamColorPrimary: 0xC4CED4, teamColorSecondary: 0x000000,
            grade: "PSA 10", sport: "NBA", style: .prizm,
            isRookie: true,
            estimatedValue: 1_350, trend30d: 0.143,
            ownerHandle: "@hoopsdaily",
            note: "Wemby era just starting. Long-term hold.",
            imageAssetName: "card_wembanyama_prizm_2023",
            market: makeMarket(currentValue: 1_350, trend30d: 0.143, grade: "PSA 10", isVintage: false)
        ),
        CardMock(
            title: "2003-04 Exquisite RPA LeBron James /23",
            year: 2003, brand: "Upper Deck Exquisite",
            playerName: "LeBron James", cardNumber: "78",
            position: "F · #/23", team: "Cleveland Cavaliers",
            teamColorPrimary: 0x860038, teamColorSecondary: 0xFDBB30,
            grade: "BGS 9.5 · Auto 10", sport: "NBA", style: .chrome,
            isRookie: true,
            estimatedValue: 2_400_000, trend30d: 0.041,
            ownerHandle: "@cardking",
            note: "23/23. The hobby's modern Mona Lisa.",
            imageAssetName: "card_lebron_exquisite_2003",
            market: makeMarket(currentValue: 2_400_000, trend30d: 0.041, grade: "BGS 9.5", isVintage: false)
        ),
        CardMock(
            title: "1952 Topps Mickey Mantle #311",
            year: 1952, brand: "Topps",
            playerName: "Mickey Mantle", cardNumber: "311",
            position: "OF", team: "New York Yankees",
            teamColorPrimary: 0x132448, teamColorSecondary: 0xC4CED4,
            grade: "PSA 8", sport: "MLB", style: .vintage,
            isRookie: false,
            estimatedValue: 1_650_000, trend30d: 0.038,
            ownerHandle: "@vintageonly",
            note: "Crown jewel. Took me 14 years to find one in this grade.",
            imageAssetName: "card_mantle_topps_1952",
            market: makeMarket(currentValue: 1_650_000, trend30d: 0.038, grade: "PSA 8", isVintage: true)
        ),
        CardMock(
            title: "2009 Bowman Chrome Trout RC Auto /500",
            year: 2009, brand: "Bowman Chrome",
            playerName: "Mike Trout", cardNumber: "BDPP89",
            position: "OF · /500", team: "LA Angels",
            teamColorPrimary: 0xBA0021, teamColorSecondary: 0x003263,
            grade: "PSA 10", sport: "MLB", style: .chrome,
            isRookie: true,
            estimatedValue: 14_500, trend30d: -0.025,
            ownerHandle: "@diamondkings",
            note: "Got this raw at a card show in 2014. PSA 10 came back clean.",
            imageAssetName: "card_trout_bowman_2009",
            market: makeMarket(currentValue: 14_500, trend30d: -0.025, grade: "PSA 10", isVintage: false)
        ),
        CardMock(
            title: "1999 Pokémon Blastoise 1st Ed #2",
            year: 1999, brand: "Pokémon",
            playerName: "Blastoise", cardNumber: "2",
            position: "Stage 2", team: "Base Set 1st Ed",
            teamColorPrimary: 0x1E40AF, teamColorSecondary: 0x60A5FA,
            grade: "PSA 10", sport: "Pokémon", style: .pokemonHolo,
            isRookie: false,
            estimatedValue: 24_999, trend30d: 0.092,
            ownerHandle: "@pokegrails",
            note: "Completing the starter trio. Charizard ✓ Blastoise ✓ Venusaur next.",
            imageAssetName: "card_blastoise_pokemon_1999",
            market: makeMarket(currentValue: 24_999, trend30d: 0.092, grade: "PSA 10", isVintage: true)
        ),
        CardMock(
            title: "1999 Pokémon Pikachu 1st Ed #58",
            year: 1999, brand: "Pokémon",
            playerName: "Pikachu", cardNumber: "58",
            position: "Basic", team: "Base Set 1st Ed",
            teamColorPrimary: 0xFACC15, teamColorSecondary: 0xDC2626,
            grade: "PSA 7", sport: "Pokémon", style: .pokemonHolo,
            isRookie: false,
            estimatedValue: 880, trend30d: 0.041,
            ownerHandle: "@pokegrails",
            imageAssetName: "card_pikachu_base_1999",
            market: makeMarket(currentValue: 880, trend30d: 0.041, grade: "PSA 7", isVintage: true)
        ),
        CardMock(
            title: "2002 Yu-Gi-Oh! Blue-Eyes WD 1st Ed",
            year: 2002, brand: "Konami",
            playerName: "Blue-Eyes White Dragon", cardNumber: "LOB-001",
            position: "Monster · ATK 3000", team: "Legend of Blue Eyes",
            teamColorPrimary: 0x1E3A8A, teamColorSecondary: 0xDBEAFE,
            grade: "PSA 10", sport: "Yu-Gi-Oh!", style: .pokemonHolo,
            isRookie: false,
            estimatedValue: 25_000, trend30d: 0.156,
            ownerHandle: "@tcgwhale",
            note: "Childhood dream. LOB-001 in PSA 10. Took 22 years.",
            imageAssetName: "card_blueeyes_yugioh_2002",
            market: makeMarket(currentValue: 25_000, trend30d: 0.156, grade: "PSA 10", isVintage: true)
        ),
        CardMock(
            title: "2002 Yu-Gi-Oh! Dark Magician 1st Ed",
            year: 2002, brand: "Konami",
            playerName: "Dark Magician", cardNumber: "LOB-005",
            position: "Spellcaster · ATK 2500", team: "Legend of Blue Eyes",
            teamColorPrimary: 0x7C3AED, teamColorSecondary: 0xF5D0FE,
            grade: "PSA 10", sport: "Yu-Gi-Oh!", style: .pokemonHolo,
            isRookie: false,
            estimatedValue: 13_561, trend30d: 0.118,
            ownerHandle: "@tcgwhale",
            imageAssetName: "card_darkmagician_yugioh_2002",
            market: makeMarket(currentValue: 13_561, trend30d: 0.118, grade: "PSA 10", isVintage: true)
        ),
        CardMock(
            title: "1993 MTG Alpha Black Lotus",
            year: 1993, brand: "Wizards of the Coast",
            playerName: "Black Lotus", cardNumber: "Alpha",
            position: "Artifact · 0 Mana", team: "Alpha · Power Nine",
            teamColorPrimary: 0x1F1F1F, teamColorSecondary: 0xC084FC,
            grade: "BGS 9.5", sport: "Magic", style: .vintage,
            isRookie: false,
            estimatedValue: 540_000, trend30d: 0.062,
            ownerHandle: "@mtgvault",
            note: "Power Nine. Alpha border. The hobby's most iconic card.",
            imageAssetName: "card_blacklotus_mtg_1993",
            market: makeMarket(currentValue: 540_000, trend30d: 0.062, grade: "BGS 9.5", isVintage: true)
        ),
        CardMock(
            title: "2018 Prizm WC Silver Mbappé RC #80",
            year: 2018, brand: "Panini Prizm",
            playerName: "Kylian Mbappé", cardNumber: "80",
            position: "F", team: "France",
            teamColorPrimary: 0x002654, teamColorSecondary: 0xED2939,
            grade: "PSA 10", sport: "Soccer", style: .prizm,
            isRookie: true,
            estimatedValue: 750, trend30d: 0.078,
            ownerHandle: "@soccerprizm",
            note: "Russia 2018 on cardboard. Madrid era now — only one direction.",
            imageAssetName: "card_mbappe_prizm_2018",
            market: makeMarket(currentValue: 750, trend30d: 0.078, grade: "PSA 10", isVintage: false)
        ),
    ]

    // MARK: — Collectors
    static let collectors: [CollectorMock] = [
        CollectorMock(handle: "@cardking",      displayName: "Marcus Reed",   avatarColorHex: 0xFF4F1F, isLive: true),
        CollectorMock(handle: "@hoopsdaily",    displayName: "Tim Bishop",    avatarColorHex: 0x1F2937),
        CollectorMock(handle: "@pokegrails",    displayName: "Yuki Sato",     avatarColorHex: 0x10B981),
        CollectorMock(handle: "@diamondkings",  displayName: "Eric Chen",     avatarColorHex: 0xEF4444),
        CollectorMock(handle: "@gridironpulls", displayName: "Tony Rivera",   avatarColorHex: 0x8B5CF6),
        CollectorMock(handle: "@vintageonly",   displayName: "Jane Park",     avatarColorHex: 0xF59E0B),
        CollectorMock(handle: "@tcgwhale",      displayName: "Kenji Watanabe", avatarColorHex: 0x1E3A8A, isLive: true),
        CollectorMock(handle: "@mtgvault",      displayName: "Drew Hartman",  avatarColorHex: 0x7C3AED),
        CollectorMock(handle: "@soccerprizm",   displayName: "Léa Dubois",    avatarColorHex: 0x002654),
    ]

    // MARK: — Posts
    static func posts() -> [PostMock] {
        struct FeedSpec {
            let assetName: String
            let caption: String
            let topComment: String
            let likes: Int
            let commentCount: Int
            let timeAgo: String
            let milestone: String?
        }

        let specs: [FeedSpec] = [
            FeedSpec(
                assetName: "card_lebron_exquisite_2003",
                caption: "23/23. Finally landed her. Auto 10, BGS 9.5. The ceiling.",
                topComment: "@cardking: hobby just stopped breathing",
                likes: 4_802, commentCount: 612, timeAgo: "1h",
                milestone: "$2.4M"
            ),
            FeedSpec(
                assetName: "card_wembanyama_prizm_2023",
                caption: "Wemby silver hit PSA 10. Long hold — gen-defining ceiling.",
                topComment: "@hoopsdaily: this aged 12 months in 12 weeks",
                likes: 2_115, commentCount: 184, timeAgo: "3h",
                milestone: nil
            ),
            FeedSpec(
                assetName: "card_blacklotus_mtg_1993",
                caption: "Power Nine secured. Alpha border, BGS 9.5. Vault piece — not for sale.",
                topComment: "@mtgvault: that border alone is a flex",
                likes: 1_834, commentCount: 247, timeAgo: "5h",
                milestone: "$540K"
            ),
            FeedSpec(
                assetName: "card_charizard_pokemon_1999",
                caption: "20+ years and still my favorite pull. 1st edition base set.",
                topComment: "@pokegrails: forever king",
                likes: 1_321, commentCount: 198, timeAgo: "8h",
                milestone: nil
            ),
            FeedSpec(
                assetName: "card_blueeyes_yugioh_2002",
                caption: "LOB-001 PSA 10. Took 22 years to land this in gem mint.",
                topComment: "@tcgwhale: childhood unlocked",
                likes: 982, commentCount: 156, timeAgo: "11h",
                milestone: nil
            ),
            FeedSpec(
                assetName: "card_jordan_fleer_1986",
                caption: "Found this at a flea market in '02. Graded last spring — worth every penny.",
                topComment: "@vintageonly: clean centering 👌",
                likes: 754, commentCount: 92, timeAgo: "1d",
                milestone: nil
            ),
            FeedSpec(
                assetName: "card_mbappe_prizm_2018",
                caption: "Russia 2018 on cardboard. Madrid era now — only one direction.",
                topComment: "@soccerprizm: Ballon d'Or year incoming",
                likes: 638, commentCount: 71, timeAgo: "1d",
                milestone: nil
            ),
            FeedSpec(
                assetName: "card_mantle_topps_1952",
                caption: "14 years of looking. Crown jewel finally home.",
                topComment: "@diamondkings: hobby Mt. Rushmore",
                likes: 3_201, commentCount: 421, timeAgo: "2d",
                milestone: "$1.65M"
            ),
        ]

        return specs.compactMap { spec -> PostMock? in
            guard let card = cards.first(where: { $0.imageAssetName == spec.assetName }) else { return nil }
            let collector = collectors.first { $0.handle == card.ownerHandle } ?? collectors[0]
            return PostMock(
                authorHandle: card.ownerHandle,
                authorAvatarColorHex: collector.avatarColorHex,
                cardID: card.id,
                cardTitle: card.title,
                cardPlayerName: card.playerName,
                cardImageColorHex: card.imageColorHex,
                caption: spec.caption,
                isForSale: card.estimatedValue > 5_000,
                listPrice: card.estimatedValue > 5_000 ? card.estimatedValue : nil,
                likes: spec.likes,
                commentCount: spec.commentCount,
                topComment: spec.topComment,
                timeAgo: spec.timeAgo,
                milestoneTreatment: spec.milestone
            )
        }
    }

    // MARK: — Market data generator
    static func makeMarket(
        currentValue: Double,
        trend30d: Double,
        grade: String?,
        isVintage: Bool
    ) -> MarketData {
        let cal = Calendar.current
        let now = Date()

        var history: [PricePoint] = []
        let startValue = currentValue * 0.65
        let weeks = 52
        for w in 0..<weeks {
            let progress = Double(w) / Double(weeks - 1)
            let base = startValue + (currentValue - startValue) * progress
            let phase = Double(w) * 0.42
            let wave = sin(phase) * currentValue * 0.04
            let micro = sin(phase * 3.7) * currentValue * 0.02
            let date = cal.date(byAdding: .weekOfYear, value: -(weeks - 1 - w), to: now) ?? now
            history.append(PricePoint(date: date, price: base + wave + micro))
        }
        if let last = history.last {
            history[history.count - 1] = PricePoint(date: last.date, price: currentValue)
        }

        let prices = history.map(\.price)
        let high = prices.max() ?? currentValue
        let low = prices.min() ?? currentValue
        let value90dAgo = history[max(0, history.count - 14)].price
        let value1yAgo = history[0].price
        let trend90d = (currentValue - value90dAgo) / value90dAgo
        let trend1y = (currentValue - value1yAgo) / value1yAgo

        let popReport: [GradeCount]
        if isVintage {
            popReport = [
                GradeCount(grade: "10",  count: Int(currentValue / 60).clamped(60...600)),
                GradeCount(grade: "9",   count: 2_245),
                GradeCount(grade: "8",   count: 4_891),
                GradeCount(grade: "7",   count: 5_234),
                GradeCount(grade: "6",   count: 3_200),
                GradeCount(grade: "≤5",  count: 12_581),
            ]
        } else {
            popReport = [
                GradeCount(grade: "10",  count: 8_412),
                GradeCount(grade: "9",   count: 12_905),
                GradeCount(grade: "8",   count: 2_634),
                GradeCount(grade: "≤7",  count: 1_120),
            ]
        }
        let totalGraded = popReport.reduce(0) { $0 + $1.count }

        var recentSales: [SaleMock] = []
        var prev = currentValue
        for i in 0..<7 {
            let daysAgo = i * 9 + Int.random(in: 0...4)
            let date = cal.date(byAdding: .day, value: -daysAgo, to: now) ?? now
            let priceVariance = Double.random(in: -0.06...0.06)
            let priceVal = currentValue * (1 + priceVariance) * (1 - Double(i) * 0.018)
            let priceChange = i == 0 ? 0 : (priceVal - prev) / prev
            recentSales.append(SaleMock(
                date: date,
                grade: grade ?? "RAW",
                price: priceVal,
                priceChange: priceChange
            ))
            prev = priceVal
        }

        return MarketData(
            lastSale: currentValue,
            trend30d: trend30d,
            trend90d: trend90d,
            trend1y: trend1y,
            priceHistory: history,
            popReport: popReport,
            totalGraded: totalGraded,
            recentSales: recentSales,
            monthlyVolume: isVintage ? Int.random(in: 8...22) : Int.random(in: 25...80),
            highSale: high,
            lowSale: low
        )
    }

    // MARK: — Comments
    static func comments(for cardID: UUID) -> [CommentMock] {
        [
            CommentMock(authorHandle: "@vintageonly",  body: "clean centering 👌", likes: 24, timeAgo: "1h"),
            CommentMock(authorHandle: "@diamondkings", body: "what a flip",         likes: 8,  timeAgo: "2h"),
            CommentMock(authorHandle: "@hoopsdaily",   body: "legendary card",      likes: 12, timeAgo: "4h"),
            CommentMock(authorHandle: "@pokegrails",   body: "GOAT",                likes: 5,  timeAgo: "6h"),
        ]
    }
}
