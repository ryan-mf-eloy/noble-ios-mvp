import SwiftUI

struct StatItem: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let valueColor: Color

    init(_ label: String, _ value: String, color: Color = .white) {
        self.label = label
        self.value = value
        self.valueColor = color
    }
}

struct StatBlock: View {
    let items: [StatItem]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                column(item)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if index < items.count - 1 {
                    Rectangle()
                        .fill(Color.nobleOrange)
                        .frame(width: 1, height: 56)
                }
            }
        }
    }

    private func column(_ item: StatItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            EyebrowText(item.label, color: .nobleMuted, size: 9)
            Text(item.value)
                .font(.druk(26))
                .foregroundStyle(item.valueColor)
        }
        .padding(.horizontal, Spacing.s)
    }
}

#Preview {
    StatBlock(items: [
        StatItem("EST. VALUE", "$28,500"),
        StatItem("30-DAY", "▲ 12.4%", color: .nobleSuccess),
        StatItem("GRADE", "PSA 9"),
    ])
    .padding(Spacing.xl)
    .background(Color.nobleBlack)
}
