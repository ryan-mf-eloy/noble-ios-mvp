import SwiftUI

struct CountdownChip: View {
    let initialMs: Int
    var urgent: Bool = false

    @State private var ms: Int
    @State private var pulse: Bool = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(initialMs: Int, urgent: Bool = false) {
        self.initialMs = initialMs
        self.urgent = urgent
        self._ms = State(initialValue: initialMs)
    }

    private var formatted: String {
        let h = ms / 3_600_000
        let m = (ms % 3_600_000) / 60_000
        let s = (ms % 60_000) / 1_000
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%d:%02d", m, s)
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(urgent ? Color.white : Color.nobleSuccess)
                .frame(width: 7, height: 7)
                .scaleEffect(pulse ? 0.55 : 1.0)
                .opacity(pulse ? 0.45 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulse)

            Text(formatted)
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(urgent ? Color.nobleLive : Color.nobleBlack)
                .overlay(
                    Capsule()
                        .strokeBorder(urgent ? Color.nobleLive : Color.nobleBorder, lineWidth: 1.5)
                )
        )
        .onAppear { pulse = true }
        .onReceive(timer) { _ in
            ms = max(0, ms - 1000)
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        CountdownChip(initialMs: 47 * 60_000 + 22_000)
        CountdownChip(initialMs: 32_000, urgent: true)
    }
    .padding()
    .background(Color.nobleBlack)
}
