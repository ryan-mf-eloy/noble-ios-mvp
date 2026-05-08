import Charts
import SwiftUI

/// Market data block — price chart, pop report, recent sales. Designed to
struct MarketSection: View {
    let card: CardMock

    @State private var timeframe: Timeframe = .y1
    @State private var showAllSales = false

    enum Timeframe: String, CaseIterable, Identifiable {
        case d30 = "30D"
        case d90 = "90D"
        case y1 = "1Y"
        case all = "ALL"
        var id: String { rawValue }
    }

    private var market: MarketData { card.market }

    private var filteredHistory: [PricePoint] {
        let cal = Calendar.current
        let cutoff: Date
        switch timeframe {
        case .d30: cutoff = cal.date(byAdding: .day, value: -30, to: Date()) ?? .distantPast
        case .d90: cutoff = cal.date(byAdding: .day, value: -90, to: Date()) ?? .distantPast
        case .y1:  cutoff = cal.date(byAdding: .year, value: -1, to: Date()) ?? .distantPast
        case .all: cutoff = .distantPast
        }
        return market.priceHistory.filter { $0.date >= cutoff }
    }

    private var trendForTimeframe: Double {
        switch timeframe {
        case .d30: market.trend30d
        case .d90: market.trend90d
        case .y1, .all: market.trend1y
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            chartBlock
            Divider().background(Color.nobleBorder)
            popReportBlock
            Divider().background(Color.nobleBorder)
            recentSalesBlock
        }
        .background(Color.nobleSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
    }

    // MARK: — Block 1: price chart

    private var chartBlock: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            HStack(alignment: .firstTextBaseline) {
                EyebrowText("MARKET", color: .nobleOrange)
                Spacer()
                EyebrowText("VOL \(market.monthlyVolume)/MO", color: .nobleMuted, size: 9)
            }

            HStack(alignment: .firstTextBaseline, spacing: Spacing.m) {
                Text("$\(formatPrice(market.lastSale))")
                    .font(.druk(38))
                    .foregroundStyle(.white)
                trendPill(trendForTimeframe)
            }

            timeframePicker
            chart
            rangeRow
        }
        .padding(Spacing.l)
    }

    private var timeframePicker: some View {
        HStack(spacing: 6) {
            ForEach(Timeframe.allCases) { tf in
                Button {
                    withAnimation(.smooth(duration: 0.35)) { timeframe = tf }
                } label: {
                    Text(tf.rawValue)
                        .font(.inter(11, weight: .black))
                        .tracking(1.2)
                        .foregroundStyle(timeframe == tf ? Color.nobleBlack : Color.nobleMuted)
                        .padding(.horizontal, Spacing.m)
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity)
                        .background(timeframe == tf ? Color.nobleOrange : Color.clear)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Color.nobleElevated)
        .clipShape(Capsule())
    }

    private var chart: some View {
        Chart {
            ForEach(filteredHistory) { point in
                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Price", point.price)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.nobleOrange.opacity(0.42),
                            Color.nobleOrange.opacity(0.02),
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Price", point.price)
                )
                .foregroundStyle(Color.nobleOrange)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 3)) { v in
                AxisGridLine().foregroundStyle(Color.nobleBorder.opacity(0.35))
                AxisValueLabel {
                    if let p = v.as(Double.self) {
                        Text("$\(formatCompact(p))")
                            .font(.inter(9, weight: .medium))
                            .foregroundStyle(Color.nobleMuted)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                AxisValueLabel(format: .dateTime.month(.abbreviated))
                    .font(.inter(9, weight: .medium))
                    .foregroundStyle(Color.nobleMuted)
            }
        }
        .frame(height: 160)
    }

    private var rangeRow: some View {
        HStack {
            stat(label: "LOW", value: "$\(formatCompact(market.lowSale))")
            Spacer()
            stat(label: "HIGH", value: "$\(formatCompact(market.highSale))")
            Spacer()
            stat(label: "AVG", value: "$\(formatCompact((market.lowSale + market.highSale) / 2))")
        }
    }

    private func stat(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            EyebrowText(label, color: .nobleMuted, size: 9)
            Text(value)
                .font(.mono(13))
                .foregroundStyle(.white)
        }
    }

    // MARK: — Block 2: pop report

    private var popReportBlock: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(alignment: .firstTextBaseline) {
                EyebrowText("POPULATION", color: .nobleOrange)
                Spacer()
                EyebrowText("\(formatNumber(market.totalGraded)) GRADED", color: .nobleMuted, size: 9)
            }

            VStack(spacing: 6) {
                let maxCount = market.popReport.map(\.count).max() ?? 1
                ForEach(market.popReport) { gc in
                    popBar(grade: gc.grade, count: gc.count, max: maxCount,
                           isOwned: gc.grade == card.grade?.replacingOccurrences(of: "PSA ", with: "")
                                                          .replacingOccurrences(of: "BGS ", with: ""))
                }
            }
        }
        .padding(Spacing.l)
    }

    private func popBar(grade: String, count: Int, max: Int, isOwned: Bool) -> some View {
        HStack(spacing: Spacing.s) {
            Text(grade)
                .font(.druk(15))
                .foregroundStyle(isOwned ? Color.nobleOrange : .white)
                .frame(width: 32, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.nobleElevated)
                    Capsule()
                        .fill(isOwned ? Color.nobleOrange : Color.nobleOrange.opacity(0.35))
                        .frame(width: geo.size.width * CGFloat(count) / CGFloat(max))
                }
            }
            .frame(height: 14)

            Text(formatNumber(count))
                .font(.mono(12))
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: 60, alignment: .trailing)
        }
    }

    // MARK: — Block 3: recent sales

    private var recentSalesBlock: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(alignment: .firstTextBaseline) {
                EyebrowText("RECENT SALES", color: .nobleOrange)
                Spacer()
                EyebrowText("LAST 90D", color: .nobleMuted, size: 9)
            }

            VStack(spacing: 10) {
                let visible = showAllSales ? market.recentSales : Array(market.recentSales.prefix(5))
                ForEach(visible) { sale in
                    saleRow(sale)
                }
            }

            if !showAllSales && market.recentSales.count > 5 {
                Button {
                    withAnimation(.smooth) { showAllSales = true }
                } label: {
                    HStack(spacing: 4) {
                        Text("View all \(market.recentSales.count) sales")
                            .font(.inter(13, weight: .black))
                            .tracking(0.5)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .black))
                    }
                    .foregroundStyle(Color.nobleOrange)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.l)
    }

    private func saleRow(_ sale: SaleMock) -> some View {
        HStack(spacing: Spacing.s) {
            Text(formatRelativeDate(sale.date))
                .font(.inter(12, weight: .medium))
                .foregroundStyle(Color.nobleMuted)
                .frame(width: 64, alignment: .leading)

            Text(sale.grade)
                .font(.inter(10, weight: .black))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .overlay(Capsule().strokeBorder(Color.nobleBorder, lineWidth: 1))

            Spacer()

            Text("$\(formatPrice(sale.price))")
                .font(.mono(13))
                .foregroundStyle(.white)

            trendIcon(sale.priceChange)
                .frame(width: 18)
        }
    }

    @ViewBuilder
    private func trendIcon(_ value: Double) -> some View {
        if value > 0.005 {
            Image(systemName: "arrow.up.right")
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(Color.nobleSuccess)
        } else if value < -0.005 {
            Image(systemName: "arrow.down.right")
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(Color.nobleLive)
        } else {
            Image(systemName: "arrow.right")
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(Color.nobleMuted)
        }
    }

    // MARK: — Trend pill

    private func trendPill(_ value: Double) -> some View {
        let positive = value >= 0
        let color: Color = positive ? .nobleSuccess : .nobleLive
        let arrow = positive ? "▲" : "▼"
        return HStack(spacing: 2) {
            Text(arrow).font(.inter(10, weight: .black))
            Text("\(String(format: "%.1f", abs(value) * 100))%")
                .font(.inter(13, weight: .black))
        }
        .foregroundStyle(color)
        .padding(.horizontal, Spacing.s)
        .padding(.vertical, 4)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }

    // MARK: — Formatters

    private func formatPrice(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: "en_US")
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }

    private func formatCompact(_ value: Double) -> String {
        if value >= 1_000_000 { return String(format: "%.1fM", value / 1_000_000) }
        if value >= 1_000 { return String(format: "%.1fK", value / 1_000) }
        return String(format: "%.0f", value)
    }

    private func formatNumber(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: "en_US")
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formatRelativeDate(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        if days == 0 { return "TODAY" }
        if days < 7 { return "\(days)d ago" }
        if days < 30 { return "\(days / 7)w ago" }
        if days < 365 { return "\(days / 30)mo ago" }
        return "\(days / 365)y ago"
    }
}

#Preview {
    ScrollView {
        MarketSection(card: MockDataProvider.cards[0])
            .padding()
    }
    .background(Color.nobleBlack)
    .preferredColorScheme(.dark)
}
