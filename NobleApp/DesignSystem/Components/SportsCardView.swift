import SwiftUI

struct SportsCardView: View {
    let card: CardMock

    private var primary: Color { Color(hex: card.teamColorPrimary) }
    private var secondary: Color { Color(hex: card.teamColorSecondary) }

    var body: some View {
        if let asset = card.imageAssetName, UIImage(named: asset) != nil {
            Image(asset)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .compositingGroup()
                .shadow(color: .black.opacity(0.55), radius: 14, x: 0, y: 6)
        } else {
            proceduralCard
                .aspectRatio(5.0 / 7.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .compositingGroup()
                .shadow(color: .black.opacity(0.55), radius: 16, x: 0, y: 8)
        }
    }

    private var proceduralCard: some View {
        ZStack {
            background
            refractor
            playerFigure
            foilShine
            content
            border
        }
    }

    // MARK: — Layer 1: background

    @ViewBuilder
    private var background: some View {
        switch card.style {
        case .vintage:
            ZStack {
                Color(hex: 0xF4EBD3)
                LinearGradient(
                    colors: [primary.opacity(0.0), primary.opacity(0.18)],
                    startPoint: .top, endPoint: .bottom
                )
            }
        case .pokemonHolo:
            LinearGradient(
                colors: [
                    Color(hex: 0xFFD650),
                    Color(hex: 0xFFB400),
                    Color(hex: 0xFFD650),
                ],
                startPoint: .top, endPoint: .bottom
            )
        default:
            ZStack {
                LinearGradient(
                    colors: [primary, primary.opacity(0.7), secondary],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                RadialGradient(
                    colors: [Color.white.opacity(0.18), .clear],
                    center: UnitPoint(x: 0.3, y: 0.25),
                    startRadius: 5, endRadius: 220
                )
            }
        }
    }

    // MARK: — Layer 2: refractor / holographic overlay

    @ViewBuilder
    private var refractor: some View {
        switch card.style {
        case .chrome:
            AngularGradient(
                colors: [
                    Color.red.opacity(0.18),
                    Color.orange.opacity(0.18),
                    Color.yellow.opacity(0.18),
                    Color.green.opacity(0.18),
                    Color.cyan.opacity(0.18),
                    Color.blue.opacity(0.18),
                    Color.purple.opacity(0.18),
                    Color.pink.opacity(0.18),
                    Color.red.opacity(0.18),
                ],
                center: .center,
                startAngle: .degrees(0),
                endAngle: .degrees(360)
            )
            .blendMode(.plusLighter)

        case .prizm:
            ZStack {
                LinearGradient(
                    colors: [
                        .clear, .cyan.opacity(0.20), .clear,
                        .pink.opacity(0.16), .clear, .yellow.opacity(0.20), .clear,
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                LinearGradient(
                    colors: [
                        .clear, .purple.opacity(0.14), .clear, .orange.opacity(0.18), .clear,
                    ],
                    startPoint: .topTrailing, endPoint: .bottomLeading
                )
            }
            .blendMode(.plusLighter)

        case .optic:
            RadialGradient(
                colors: [
                    .yellow.opacity(0.22),
                    .cyan.opacity(0.15),
                    .pink.opacity(0.18),
                    .clear,
                ],
                center: UnitPoint(x: 0.5, y: 0.4),
                startRadius: 10, endRadius: 280
            )
            .blendMode(.plusLighter)

        case .vintage:
            EmptyView()

        case .pokemonHolo:
            AngularGradient(
                colors: [
                    Color.red.opacity(0.4),
                    Color.orange.opacity(0.4),
                    Color.yellow.opacity(0.4),
                    Color.green.opacity(0.4),
                    Color.cyan.opacity(0.4),
                    Color.purple.opacity(0.4),
                    Color.pink.opacity(0.4),
                    Color.red.opacity(0.4),
                ],
                center: .center,
                startAngle: .degrees(45), endAngle: .degrees(405)
            )
            .blendMode(.plusLighter)
            .opacity(0.7)
        }
    }

    // MARK: — Layer 3: player figure

    @ViewBuilder
    private var playerFigure: some View {
        let symbol = sportSymbol

        if card.style == .pokemonHolo {
            Image(systemName: "flame.fill")
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.orange)
                .padding(.horizontal, 24)
                .padding(.top, 38)
                .padding(.bottom, 92)
                .shadow(color: .red, radius: 18, y: 0)
                .shadow(color: .yellow.opacity(0.8), radius: 12, y: 0)
        } else if card.style == .vintage {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(LinearGradient(
                        colors: [primary.opacity(0.95), primary, secondary],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))

                Image(systemName: symbol)
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
                    .padding(12)
                    .shadow(color: .black.opacity(0.5), radius: 6, y: 3)
            }
            .padding(.horizontal, 14)
            .padding(.top, 26)
            .padding(.bottom, 76)
        } else {
            Image(systemName: symbol)
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.top, 32)
                .padding(.bottom, 88)
                .shadow(color: secondary, radius: 22, y: 0)
                .shadow(color: .black.opacity(0.65), radius: 12, y: 6)
        }
    }

    private var sportSymbol: String {
        switch card.sport {
        case "NBA":     "figure.basketball"
        case "NFL":     "figure.american.football"
        case "MLB":     "figure.baseball"
        case "NHL":     "figure.hockey"
        case "Pokémon": "flame.fill"
        default:        "sparkles"
        }
    }

    // MARK: — Layer 4: foil chrome shine (top edge highlight)

    private var foilShine: some View {
        LinearGradient(
            stops: [
                .init(color: .white.opacity(0.45), location: 0),
                .init(color: .white.opacity(0.10), location: 0.18),
                .init(color: .clear, location: 0.45),
            ],
            startPoint: .top, endPoint: .bottom
        )
        .blendMode(.plusLighter)
        .allowsHitTesting(false)
    }

    // MARK: — Layer 5: content (brand, name, badges)

    @ViewBuilder
    private var content: some View {
        if card.style == .pokemonHolo {
            pokemonContent
        } else if card.style == .vintage {
            vintageContent
        } else {
            modernContent
        }
    }

    private var modernContent: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Text(card.brand.uppercased())
                    .font(.inter(8, weight: .black))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Spacer(minLength: 4)
                Text("#\(card.cardNumber)")
                    .font(.inter(8, weight: .black))
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                if card.isRookie {
                    Text("RC")
                        .font(.inter(7, weight: .black))
                        .tracking(1)
                        .foregroundStyle(Color.nobleBlack)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Color.nobleYellow)
                        .clipShape(Capsule())
                        .padding(.bottom, 2)
                }

                Text(card.playerName.uppercased())
                    .font(.druk(20))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)

                HStack(spacing: 4) {
                    Text(card.position)
                        .font(.inter(8, weight: .black))
                        .tracking(1)
                        .foregroundStyle(secondary)
                        .lineLimit(1)
                    Rectangle()
                        .fill(secondary.opacity(0.7))
                        .frame(width: 8, height: 1)
                    Text(card.team.uppercased())
                        .font(.inter(7, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [.black.opacity(0.0), .black.opacity(0.85)],
                    startPoint: .top, endPoint: .bottom
                )
            )
        }
    }

    private var vintageContent: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Rectangle().fill(primary).frame(width: 16)
                Text("\(card.brand) · \(card.year)".uppercased())
                    .font(.inter(7, weight: .black))
                    .tracking(2)
                    .foregroundStyle(Color.nobleBlack)
                    .padding(.horizontal, 8)
                Spacer()
                Text("#\(card.cardNumber)")
                    .font(.inter(7, weight: .black))
                    .foregroundStyle(Color.nobleBlack)
                    .padding(.trailing, 8)
                Rectangle().fill(secondary).frame(width: 16)
            }
            .frame(height: 16)
            .background(Color.white.opacity(0.55))

            Spacer()

            VStack(alignment: .leading, spacing: 1) {
                Text(card.playerName.uppercased())
                    .font(.inter(15, weight: .black))
                    .tracking(0.5)
                    .foregroundStyle(Color.nobleBlack)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                HStack(spacing: 4) {
                    Text(card.position)
                        .font(.inter(8, weight: .black))
                        .foregroundStyle(primary)
                    Text("·")
                        .font(.inter(8))
                        .foregroundStyle(.black.opacity(0.4))
                    Text(card.team.uppercased())
                        .font(.inter(7, weight: .bold))
                        .foregroundStyle(.black.opacity(0.7))
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.85))
        }
    }

    private var pokemonContent: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 4) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(card.position.uppercased())
                        .font(.inter(6, weight: .black))
                        .foregroundStyle(.black.opacity(0.7))
                        .lineLimit(1)
                    Text(card.playerName)
                        .font(.inter(13, weight: .black))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                Spacer(minLength: 4)
                HStack(spacing: 1) {
                    Text("HP")
                        .font(.inter(6, weight: .black))
                        .foregroundStyle(.red)
                    Text("120")
                        .font(.inter(13, weight: .black))
                        .foregroundStyle(.red)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(.red, .orange)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 6)

            Spacer()

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                            .overlay {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 5, weight: .black))
                                    .foregroundStyle(.yellow)
                            }
                    }
                    Text("FIRE SPIN")
                        .font(.inter(7, weight: .black))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                    Spacer(minLength: 2)
                    Text("100")
                        .font(.inter(11, weight: .black))
                        .foregroundStyle(.black)
                }
                Text("Discard 2 Energy cards attached.")
                    .font(.inter(5, weight: .regular))
                    .foregroundStyle(.black.opacity(0.7))
                    .lineLimit(2)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.85))
        }
    }

    // MARK: — Layer 6: border frame (style-specific)

    @ViewBuilder
    private var border: some View {
        switch card.style {
        case .vintage:
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color.white.opacity(0.8), lineWidth: 6)
        case .pokemonHolo:
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color(hex: 0xC8A030), lineWidth: 4)
        default:
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.15),
                            Color.black.opacity(0.4),
                        ],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )
        }
    }
}

#Preview("All styles") {
    ScrollView {
        VStack(spacing: 24) {
            ForEach(MockDataProvider.cards) { card in
                SportsCardView(card: card)
                    .frame(maxWidth: 280)
            }
        }
        .padding()
    }
    .background(Color.nobleBlack)
    .preferredColorScheme(.dark)
}
