import SwiftUI

enum OnboardingStep: Equatable {
    case welcome
    case signIn
    case interests
    case main
}

struct AppRouter: View {
    @State private var step: OnboardingStep = AppRouter.initialStep()

    private static func initialStep() -> OnboardingStep {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("--start-main") { return .main }
        if args.contains("--start-interests") { return .interests }
        if args.contains("--start-signin") { return .signIn }
        return .welcome
    }

    var body: some View {
        ZStack {
            switch step {
            case .welcome:
                WelcomeView(
                    onContinue: { advance(to: .signIn) },
                    onSignIn: { advance(to: .signIn) }
                )
                .transition(.opacity)

            case .signIn:
                SignInView(onSignedIn: { advance(to: .interests) })
                    .transition(.opacity)

            case .interests:
                PickInterestsView { _ in advance(to: .main) }
                    .transition(.opacity)

            case .main:
                MainView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: step)
    }

    private func advance(to next: OnboardingStep) {
        step = next
    }
}

#Preview {
    AppRouter()
}
