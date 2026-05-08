import SwiftUI
import UIKit

private struct InterestCategory: Identifiable, Hashable {
    let id: String
    let label: String
    let bgColor: Color
    let textColor: Color
    let icon: String

    static let all: [InterestCategory] = [
        .init(id: "nba",     label: "NBA",     bgColor: .nobleOrange, textColor: .nobleBlack,  icon: "basketball.fill"),
        .init(id: "nfl",     label: "NFL",     bgColor: .nobleBlack,  textColor: .nobleOrange, icon: "football.fill"),
        .init(id: "mlb",     label: "MLB",     bgColor: .nobleYellow, textColor: .nobleBlack,  icon: "baseball.fill"),
        .init(id: "nhl",     label: "NHL",     bgColor: .nobleBlack,  textColor: .white,       icon: "hockey.puck.fill"),
        .init(id: "pokemon", label: "POKÉMON", bgColor: .nobleOrange, textColor: .nobleBlack,  icon: "bolt.fill"),
        .init(id: "magic",   label: "MAGIC",   bgColor: .nobleBlack,  textColor: .nobleYellow, icon: "wand.and.stars"),
        .init(id: "f1",      label: "F1",      bgColor: .nobleYellow, textColor: .nobleBlack,  icon: "car.fill"),
        .init(id: "soccer",  label: "SOCCER",  bgColor: .nobleBlack,  textColor: .white,       icon: "soccerball"),
    ]
}

struct PickInterestsView: View {
    @State private var selected: Set<String> = []
    let onContinue: ([String]) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.m),
        GridItem(.flexible(), spacing: Spacing.m),
    ]

    private var canContinue: Bool { selected.count >= 3 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.xxl)

                LazyVGrid(columns: columns, spacing: Spacing.m) {
                    ForEach(InterestCategory.all) { tile(for: $0) }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.xl)
            }
        }
        .scrollIndicators(.hidden)
        .contentMargins(.bottom, 80, for: .scrollContent)
        .scrollEdgeEffectStyle(.soft, for: .bottom)
        .background(Color.nobleBlack.ignoresSafeArea())
        .overlay(alignment: .bottom) {
            cta
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.s)
        }
    }

    // MARK: — Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            EyebrowText("01 / 02")
            VStack(alignment: .leading, spacing: -8) {
                DisplayText("WHAT DO YOU", size: 44)
                DisplayText("COLLECT?", size: 44)
            }
            Text("Pick 3 or more. We'll tune your feed.")
                .font(.inter(15, weight: .medium))
                .foregroundStyle(Color.nobleMuted)
                .padding(.top, Spacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func tile(for category: InterestCategory) -> some View {
        let isSelected = selected.contains(category.id)

        return Button {
            toggle(category)
        } label: {
            ZStack {
                category.bgColor

                VStack(spacing: Spacing.s) {
                    Image(systemName: category.icon)
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(category.textColor)
                    Text(category.label)
                        .font(.druk(28))
                        .foregroundStyle(category.textColor)
                }

                if isSelected {
                    selectionMark
                }
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: Radius.sharp))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.sharp)
                    .strokeBorder(isSelected ? Color.nobleYellow : Color.clear, lineWidth: 3)
            )
            .scaleEffect(isSelected ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }

    private var selectionMark: some View {
        VStack {
            HStack {
                Spacer()
                ZStack {
                    Circle().fill(Color.nobleYellow).frame(width: 28, height: 28)
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(Color.nobleBlack)
                }
                .padding(Spacing.s)
            }
            Spacer()
        }
    }

    private var cta: some View {
        Button {
            guard canContinue else { return }
            onContinue(Array(selected))
        } label: {
            Text(canContinue ? "CONTINUE →" : "PICK \(3 - selected.count) MORE")
                .font(.inter(15, weight: .black))
                .tracking(1.5)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .tint(.nobleOrange)
        .controlSize(.large)
        .opacity(canContinue ? 1.0 : 0.4)
        .disabled(!canContinue)
    }

    private func toggle(_ category: InterestCategory) {
        UISelectionFeedbackGenerator().selectionChanged()
        if selected.contains(category.id) {
            selected.remove(category.id)
        } else {
            selected.insert(category.id)
        }
    }
}

#Preview {
    PickInterestsView(onContinue: { _ in })
}
