import AuthenticationServices
import SwiftUI

struct SignInView: View {
    let onSignedIn: () -> Void

    var body: some View {
        ZStack {
            Color.nobleBlack.ignoresSafeArea()

            VStack(spacing: 0) {
                topMark
                Spacer().frame(height: Spacing.hero)
                heroHeadline
                Spacer()
                authStack
            }
        }
    }

    // MARK: — Sections

    private var topMark: some View {
        AsteriskMark(size: 32, color: .nobleOrange)
            .padding(.top, Spacing.xxl)
    }

    private var heroHeadline: some View {
        VStack(spacing: Spacing.s) {
            DisplayText("SIGN IN", size: 72)
            Text("to your collection.")
                .font(.caveat(36))
                .foregroundStyle(Color.nobleOrange)
                .rotationEffect(.degrees(-2))
        }
    }

    private var authStack: some View {
        VStack(spacing: Spacing.m) {
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                handleAppleSignIn(result)
            }
            .signInWithAppleButtonStyle(.white)
            .frame(height: 56)
            .clipShape(RoundedRectangle(cornerRadius: Radius.sharp))

            NobleButton(
                "CONTINUE WITH GOOGLE",
                style: .secondaryOutlined,
                fullWidth: true
            ) {
                onSignedIn()
            }

            Button {
                onSignedIn()
            } label: {
                Text("Continue with email →")
                    .font(.inter(14, weight: .medium))
                    .foregroundStyle(Color.nobleMuted)
                    .padding(.top, Spacing.s)
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.bottom, Spacing.xxl)
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success:
            onSignedIn()
        case let .failure(error):
            print("Apple sign-in failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SignInView(onSignedIn: {})
}
