import SwiftUI
import UIKit

private enum PortfolioRange: String, CaseIterable, Hashable {
    case d1 = "1D", w1 = "1W", m1 = "1M", m3 = "3M", y1 = "1Y", all = "ALL"
}

struct PortfolioView: View {
    @State private var range: PortfolioRange = .m1
    @State private var selectedCard: CardMock?
    @State private var scrubbedIndex: Int? = nil

    private let holdings = AuctionMockProvider.holdings
    private let topMovers = AuctionMockProvider.topMovers

    private var currentValues: [Double] { Self.chartData(for: range) }

    private var displayedValue: Double {
        if let i = scrubbedIndex, i < currentValues.count { return currentValues[i] }
        return currentValues.last ?? 38_050
    }

    private var displayedStart: Double {
        currentValues.first ?? displayedValue
    }

    private var displayedDelta: Double { displayedValue - displayedStart }
    private var displayedDeltaPct: Double {
        guard displayedStart > 0 else { return 0 }
        return displayedDelta / displayedStart * 100
    }
    private var isUp: Bool { displayedDelta >= 0 }

    var body: some View {
        ZStack {
            Color.nobleBlack.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, Spacing.l)
                        .padding(.top, 8)
                    totalValueHero
                        .padding(.horizontal, Spacing.l)
                        .padding(.top, Spacing.l)
                    chartArea
                        .padding(.horizontal, Spacing.l)
                        .padding(.top, 16)
                    statRow
                        .padding(.horizontal, Spacing.l)
                        .padding(.top, 16)
                    topMoversSection
                        .padding(.top, 24)
                    holdingsSection
                        .padding(.horizontal, Spacing.l)
                        .padding(.top, 24)
                        .padding(.bottom, 100)
                }
            }
            .scrollIndicators(.hidden)
            .scrollDisabled(scrubbedIndex != nil)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $selectedCard) { card in
            NavigationStack { CardDetailView(card: card) }
                .presentationBackground(Color.nobleBlack)
        }
    }

    // MARK: — Header

    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                Avatar(size: 36, hue: 120)
                VStack(alignment: .leading, spacing: 0) {
                    Text("@cardking")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(Color.nobleMuted)
                    Text("PORTFOLIO")
                        .font(.druk(18))
                        .foregroundStyle(.white)
                }
            }
            Spacer()
        }
    }

    // MARK: — Total value hero

    private var totalValueHero: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(scrubbedIndex == nil ? "TOTAL COLLECTION VALUE" : "VALUE AT POINT")
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .foregroundStyle(Color.nobleMuted)
                .animation(.easeOut(duration: 0.15), value: scrubbedIndex)

            Text(currencyString(displayedValue))
                .font(.druk(56))
                .tracking(-2)
                .foregroundStyle(.white)
                .monospacedDigit()
                .contentTransition(.numericText(value: displayedValue))
                .animation(.snappy(duration: 0.18), value: displayedValue)

            HStack(spacing: 6) {
                Text("\(isUp ? "▲" : "▼") \(deltaString(abs(displayedDelta)))")
                    .font(.inter(16, weight: .black))
                    .foregroundStyle(isUp ? Color.nobleSuccess : Color.nobleLive)
                Text("\(isUp ? "+" : "")\(String(format: "%.2f", displayedDeltaPct))%")
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundStyle(isUp ? Color.nobleSuccess : Color.nobleLive)
                Text("· \(range.rawValue)")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.nobleMuted)
            }
            .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: — Chart

    private var chartArea: some View {
        VStack(spacing: 12) {
            InteractiveChart(
                values: currentValues,
                isUp: isUp,
                scrubbedIndex: $scrubbedIndex
            )
            .id(range)
            .frame(height: 180)

            HStack(spacing: 4) {
                ForEach(PortfolioRange.allCases, id: \.self) { r in
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            range = r
                        }
                    } label: {
                        Text(r.rawValue)
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundStyle(range == r ? Color.nobleBlack : Color.nobleMuted)
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                            .background(
                                Capsule().fill(range == r ? Color.white : .clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(
                Capsule()
                    .fill(Color.nobleSurface)
                    .overlay(Capsule().strokeBorder(Color.nobleBorder, lineWidth: 1))
            )
        }
    }

    // MARK: — Stats row

    private var statRow: some View {
        HStack(spacing: 8) {
            statBox(label: "CARDS", value: "47", color: .white)
            statBox(label: "BEST DAY", value: "+$1.2K", color: .nobleSuccess)
            statBox(label: "REALIZED", value: "$8,400", color: .white)
        }
    }

    private func statBox(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .black, design: .monospaced))
                .foregroundStyle(Color.nobleMuted)
            Text(value)
                .font(.druk(18))
                .tracking(-0.5)
                .foregroundStyle(color)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.nobleSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.nobleBorder, lineWidth: 1.5)
                )
        )
    }

    // MARK: — Top movers

    private var topMoversSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TOP MOVERS · 7D")
                    .font(.druk(16))
                    .foregroundStyle(.white)
                Spacer()
                Text("SEE ALL →")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.nobleOrange)
            }
            .padding(.horizontal, Spacing.l)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(topMovers) { m in
                        moverCard(m)
                    }
                }
                .padding(.horizontal, Spacing.l)
            }
        }
    }

    private func moverCard(_ m: PortfolioHolding) -> some View {
        Button {
            selectedCard = m.card
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                SportsCardView(card: m.card)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 4)
                Text(m.card.playerName.uppercased())
                    .font(.druk(12))
                    .tracking(-0.2)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                HStack {
                    Text(m.currentValue.nobleCurrency)
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundStyle(.white)
                    Spacer()
                    Text(m.diffPercent)
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundStyle(m.isUp ? Color.nobleSuccess : Color.nobleLive)
                }
                Sparkline(width: 128, height: 20, isUp: m.isUp)
            }
            .padding(12)
            .frame(width: 152)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.nobleSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.nobleBorder, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: — Holdings

    private var holdingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HOLDINGS · 47")
                .font(.druk(16))
                .foregroundStyle(.white)

            VStack(spacing: 0) {
                ForEach(Array(holdings.enumerated()), id: \.element.id) { idx, h in
                    holdingRow(h)
                    if idx < holdings.count - 1 {
                        Rectangle().fill(Color.nobleBorder).frame(height: 1).padding(.leading, 60)
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
    }

    private func holdingRow(_ h: PortfolioHolding) -> some View {
        Button {
            selectedCard = h.card
        } label: {
            HStack(spacing: 10) {
                SportsCardView(card: h.card)
                    .frame(width: 38, height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(h.card.playerName)
                        .font(.inter(13, weight: .black))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text("COST \(h.cost.nobleCurrency)")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(Color.nobleMuted)
                }
                Spacer()
                Sparkline(width: 56, height: 20, isUp: h.isUp)
                VStack(alignment: .trailing, spacing: 2) {
                    Text(h.currentValue.nobleCurrency)
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundStyle(.white)
                    Text(h.diffPercent)
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(h.isUp ? Color.nobleSuccess : Color.nobleLive)
                }
                .frame(minWidth: 64, alignment: .trailing)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    // MARK: — Helpers

    private func currencyString(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "en_US")
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
    }

    private func deltaString(_ value: Double) -> String {
        currencyString(value)
    }

    private static func chartData(for range: PortfolioRange) -> [Double] {
        let target = 38_050.0
        let count: Int = {
            switch range {
            case .d1: 28
            case .w1: 16
            case .m1: 32
            case .m3: 50
            case .y1: 60
            case .all: 84
            }
        }()
        let amplitude: Double = {
            switch range {
            case .d1: 700
            case .w1: 1_400
            case .m1: 2_300
            case .m3: 3_800
            case .y1: 6_500
            case .all: 11_000
            }
        }()
        let startMult: Double = {
            switch range {
            case .d1: 0.985
            case .w1: 0.955
            case .m1: 0.872
            case .m3: 0.78
            case .y1: 0.61
            case .all: 0.42
            }
        }()
        let start = target * startMult
        var values: [Double] = []
        for i in 0..<count {
            let progress = Double(i) / Double(max(1, count - 1))
            let base = start + (target - start) * progress
            let phase = Double(i) * 0.42
            let wave1 = sin(phase) * amplitude * 0.55
            let wave2 = cos(phase * 0.62 + 1.3) * amplitude * 0.32
            let micro = sin(phase * 3.7) * amplitude * 0.16
            let drawdown = (progress > 0.55 && progress < 0.72) ? -amplitude * 0.4 : 0
            values.append(max(0, base + wave1 + wave2 + micro + drawdown))
        }
        if !values.isEmpty { values[values.count - 1] = target }
        return values
    }
}

// MARK: — Interactive chart

private struct InteractiveChart: View {
    let values: [Double]
    let isUp: Bool
    @Binding var scrubbedIndex: Int?

    @State private var pathProgress: CGFloat = 0
    @State private var endPulse: Bool = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let pad: CGFloat = 14
            let plotH = max(1, h - pad * 2)
            let minV = values.min() ?? 0
            let maxV = values.max() ?? 1
            let rangeV = max(1, maxV - minV)

            let points: [CGPoint] = values.enumerated().map { i, v in
                let x = values.count > 1 ? CGFloat(i) / CGFloat(values.count - 1) * w : w / 2
                let yNorm = CGFloat((v - minV) / rangeV)
                let y = pad + plotH - yNorm * plotH
                return CGPoint(x: x, y: y)
            }

            let lineColor: Color = isUp ? .nobleSuccess : .nobleLive

            ZStack {
                Path { p in
                    for f: CGFloat in [0, 0.5, 1] {
                        let y = pad + plotH * f
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: w, y: y))
                    }
                }
                .stroke(Color.nobleBorder, style: StrokeStyle(lineWidth: 1, dash: [2, 4]))

                areaPath(points: points, w: w, h: h)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: lineColor.opacity(0.45), location: 0.0),
                                .init(color: lineColor.opacity(0.18), location: 0.45),
                                .init(color: lineColor.opacity(0.0),  location: 1.0)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .mask(
                        HStack(spacing: 0) {
                            Rectangle().frame(width: w * pathProgress)
                            Spacer(minLength: 0)
                        }
                    )

                smoothCurve(points: points)
                    .trim(from: 0, to: pathProgress)
                    .stroke(lineColor.opacity(0.55),
                            style: StrokeStyle(lineWidth: 9, lineCap: .round, lineJoin: .round))
                    .blur(radius: 7)

                smoothCurve(points: points)
                    .trim(from: 0, to: pathProgress)
                    .stroke(lineColor.opacity(0.6),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .blur(radius: 2)

                smoothCurve(points: points)
                    .trim(from: 0, to: pathProgress)
                    .stroke(lineColor,
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                if scrubbedIndex == nil, let last = points.last {
                    Circle()
                        .fill(lineColor.opacity(0.35))
                        .frame(width: endPulse ? 36 : 14, height: endPulse ? 36 : 14)
                        .opacity(endPulse ? 0 : 0.7)
                        .position(last)
                        .animation(
                            .easeOut(duration: 1.6).repeatForever(autoreverses: false),
                            value: endPulse
                        )
                    Circle()
                        .fill(.white)
                        .frame(width: 12, height: 12)
                        .position(last)
                    Circle()
                        .fill(lineColor)
                        .frame(width: 7, height: 7)
                        .position(last)
                        .opacity(pathProgress > 0.95 ? 1 : 0)
                }

                if let idx = scrubbedIndex, idx < points.count {
                    let p = points[idx]

                    Path { path in
                        path.move(to: CGPoint(x: p.x, y: pad))
                        path.addLine(to: CGPoint(x: p.x, y: pad + plotH))
                    }
                    .stroke(Color.white.opacity(0.55),
                            style: StrokeStyle(lineWidth: 1, dash: [3, 4]))

                    Circle()
                        .fill(lineColor.opacity(0.35))
                        .frame(width: 28, height: 28)
                        .blur(radius: 6)
                        .position(p)
                    Circle()
                        .fill(.white)
                        .frame(width: 16, height: 16)
                        .position(p)
                    Circle()
                        .fill(lineColor)
                        .frame(width: 9, height: 9)
                        .position(p)
                }
            }
            .contentShape(Rectangle())
            .gesture(scrubGesture(width: w, points: points))
        }
        .onAppear {
            pathProgress = 0
            withAnimation(.easeInOut(duration: 0.95)) {
                pathProgress = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                endPulse = true
            }
        }
    }

    private func scrubGesture(width: CGFloat, points: [CGPoint]) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard width > 0, points.count > 1 else { return }
                let progress = max(0, min(1, value.location.x / width))
                let idx = Int((progress * CGFloat(points.count - 1)).rounded())
                if scrubbedIndex != idx {
                    scrubbedIndex = idx
                    UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)
                }
            }
            .onEnded { _ in
                scrubbedIndex = nil
            }
    }

    private func smoothCurve(points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first, points.count > 1 else { return path }
        path.move(to: first)
        for i in 0..<(points.count - 1) {
            let p0 = i == 0 ? points[i] : points[i - 1]
            let p1 = points[i]
            let p2 = points[i + 1]
            let p3 = i + 2 < points.count ? points[i + 2] : p2
            let c1 = CGPoint(
                x: p1.x + (p2.x - p0.x) / 6,
                y: p1.y + (p2.y - p0.y) / 6
            )
            let c2 = CGPoint(
                x: p2.x - (p3.x - p1.x) / 6,
                y: p2.y - (p3.y - p1.y) / 6
            )
            path.addCurve(to: p2, control1: c1, control2: c2)
        }
        return path
    }

    private func areaPath(points: [CGPoint], w: CGFloat, h: CGFloat) -> Path {
        var path = smoothCurve(points: points)
        guard let first = points.first, let last = points.last else { return path }
        path.addLine(to: CGPoint(x: last.x, y: h))
        path.addLine(to: CGPoint(x: first.x, y: h))
        path.closeSubpath()
        return path
    }
}

#Preview {
    PortfolioView()
}
