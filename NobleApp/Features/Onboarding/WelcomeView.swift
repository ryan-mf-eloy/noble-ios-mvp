import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void
    let onSignIn: () -> Void

    var body: some View {
        ZStack {
            Color.nobleOrange.ignoresSafeArea()
            HalftonePattern(
                dotSize: 2,
                spacing: 14,
                color: .nobleBlack.opacity(0.10)
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                Spacer(minLength: 0)
                heroHeadline
                subhead
                Spacer(minLength: 0)
                ctaStack
            }
        }
    }

    // MARK: — Sections

    private var topBar: some View {
        HStack {
            AsteriskMark(size: 28, color: .nobleBlack)
            Spacer()
            Image(systemName: "ellipsis")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.nobleBlack)
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.s)
    }

    private var heroHeadline: some View {
        VStack(alignment: .leading, spacing: -10) {
            DisplayText("YOUR", size: 88, color: .nobleBlack)
            DisplayText("COLLECTION", size: 88, color: .nobleBlack)
            DisplayText("IN 3D", size: 88, color: .nobleBlack)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.xl)
    }

    private var subhead: some View {
        Text("Capture · Showcase · Trade — built for collectors who give a damn.")
            .font(.inter(17, weight: .medium))
            .foregroundStyle(Color.nobleBlack)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.xl)
            .padding(.top, Spacing.xl)
    }

    private var ctaStack: some View {
        VStack(spacing: Spacing.l) {
            NobleButton(
                "GET STARTED →",
                style: .primaryBlack,
                fullWidth: true,
                action: onContinue
            )

            Button(action: onSignIn) {
                Text("I already have an account")
                    .font(.inter(15, weight: .bold))
                    .underline()
                    .foregroundStyle(Color.nobleBlack)
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.bottom, Spacing.xl)
    }
}

#Preview {
    WelcomeView(onContinue: {}, onSignIn: {})
}
