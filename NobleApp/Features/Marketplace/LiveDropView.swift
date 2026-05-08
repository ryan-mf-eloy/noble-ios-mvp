import SwiftUI

struct LiveDropView: View {
    let onClose: () -> Void

    @State private var visibleChats: Int = 3
    @State private var chatTick: Int = 0
    private let timer = Timer.publish(every: 1.7, on: .main, in: .common).autoconnect()

    private let chats = AuctionMockProvider.liveChat
    private let card = MockDataProvider.cards[0]

    var body: some View {
        ZStack {
            Color.nobleBlack.ignoresSafeArea()

            VStack(spacing: 0) {
                videoStage
                    .frame(height: 466)

                chatStream
                    .frame(maxHeight: .infinity)

                bottomBar
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .ignoresSafeArea(.keyboard)
        .onReceive(timer) { _ in
            chatTick += 1
            visibleChats = 3 + (chatTick % 4)
        }
    }

    // MARK: — Video stage

    private var videoStage: some View {
        ZStack {
            RadialGradient(
                colors: [Color(hex: 0x5A1F0E), Color(hex: 0x1A0807), Color.nobleBlack],
                center: .init(x: 0.5, y: 0.4),
                startRadius: 30, endRadius: 380
            )
            HalftonePattern(dotSize: 1.4, spacing: 5, color: Color.nobleOrange.opacity(0.12))

            VStack {
                topBar
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                hostRow
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                Spacer()

                heroCard

                Spacer()

                nowUpPanel
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
            }
        }
        .clipped()
    }

    private var topBar: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(
                        Circle().fill(Color.black.opacity(0.5))
                            .overlay(Circle().strokeBorder(Color.nobleBorder, lineWidth: 1))
                    )
            }
            .buttonStyle(.plain)
            Spacer()
            HStack(spacing: 6) {
                Circle().fill(.white).frame(width: 6, height: 6)
                Text("LIVE · 847")
                    .font(.inter(10, weight: .black))
                    .tracking(1)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.nobleLive))
        }
    }

    private var hostRow: some View {
        HStack(spacing: 8) {
            Avatar(size: 36, hue: 30, ring: .white)
            VStack(alignment: .leading, spacing: 0) {
                Text("WAX SESSIONS")
                    .font(.druk(13))
                    .foregroundStyle(.white)
                Text("@waxsessions · LIVE 47m")
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.nobleMuted)
            }
            Spacer()
            Button { } label: {
                Text("+ FOLLOW")
                    .font(.inter(11, weight: .black))
                    .tracking(1)
                    .foregroundStyle(Color.nobleBlack)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(.white))
            }
            .buttonStyle(.plain)
        }
    }

    private var heroCard: some View {
        SportsCardView(card: card)
            .frame(width: 180)
            .rotationEffect(.degrees(-2))
    }

    private var nowUpPanel: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("NOW UP · LOT 7 OF 12")
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.nobleOrange)
                Text("'86 PREMIER ROOKIE")
                    .font(.druk(15))
                    .tracking(-0.3)
                    .foregroundStyle(.white)
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("$1,250")
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .foregroundStyle(.white)
                    Text("+$50")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(Color.nobleSuccess)
                    Text("· 23 BIDS")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(Color.nobleMuted)
                }
            }
            Spacer()
            CountdownChip(initialMs: 32_000, urgent: true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.nobleSurface.opacity(0.85))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.nobleOrange, lineWidth: 1.5)
                )
        )
    }

    // MARK: — Chat stream

    private var chatStream: some View {
        let count = min(visibleChats, chats.count)
        let visible = Array(chats.prefix(count))
        return VStack(alignment: .leading, spacing: 10) {
            Spacer()
            ForEach(visible.reversed(), id: \.id) { msg in
                chatRow(msg)
                    .id("\(chatTick)-\(msg.id)")
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .animation(.easeOut(duration: 0.3), value: chatTick)
    }

    private func chatRow(_ m: LiveChatMessage) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Avatar(size: 22, hue: m.avatarHue)
            (
                Text("@\(m.user) ")
                    .foregroundStyle(m.isFire ? Color.nobleOrange : Color.nobleYellow)
                    .font(.inter(13, weight: .black))
                +
                Text(m.text)
                    .foregroundStyle(.white)
                    .font(.inter(13))
            )
            .lineLimit(2)
            Spacer()
        }
    }

    // MARK: — Bottom bar

    private var bottomBar: some View {
        HStack(spacing: 8) {
            HStack {
                Text("Say something…")
                    .font(.inter(14))
                    .foregroundStyle(Color.nobleMuted)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(
                Capsule().fill(Color.nobleSurface)
                    .overlay(Capsule().strokeBorder(Color.nobleBorder, lineWidth: 1.5))
            )

            Button { } label: {
                Text("BID +$50")
                    .font(.druk(14))
                    .tracking(-0.2)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .frame(height: 44)
                    .background(Capsule().fill(Color.nobleOrange))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 24)
    }
}

#Preview {
    LiveDropView(onClose: {})
}
