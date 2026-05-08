import SwiftUI

struct StoriesRail: View {
    let collectors: [CollectorMock] = MockDataProvider.collectors

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.l) {
                ForEach(collectors) { collector in
                    storyAvatar(for: collector)
                }
            }
            .padding(.horizontal, Spacing.xl)
        }
        .padding(.vertical, Spacing.m)
    }

    private func storyAvatar(for collector: CollectorMock) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .strokeBorder(
                        collector.isLive ? Color.nobleYellow : Color.nobleOrange,
                        lineWidth: 2
                    )
                    .frame(width: 64, height: 64)

                Circle()
                    .fill(Color(hex: collector.avatarColorHex))
                    .frame(width: 54, height: 54)
                    .overlay {
                        Text(initials(for: collector.handle))
                            .font(.inter(18, weight: .black))
                            .foregroundStyle(.white)
                    }

                if collector.isLive {
                    VStack {
                        Spacer()
                        EyebrowText("LIVE", color: .white, size: 8)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.nobleLive)
                            .clipShape(Capsule())
                            .offset(y: 6)
                    }
                }
            }

            Text(collector.handle)
                .font(.inter(11, weight: .medium))
                .foregroundStyle(Color.nobleMuted)
                .lineLimit(1)
                .frame(maxWidth: 64)
        }
    }

    private func initials(for handle: String) -> String {
        let stripped = handle.replacingOccurrences(of: "@", with: "")
        let chars = stripped.prefix(2).uppercased()
        return String(chars)
    }
}

#Preview {
    StoriesRail()
        .background(Color.nobleBlack)
}
