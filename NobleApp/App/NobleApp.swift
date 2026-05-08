import SwiftUI

@main
struct NobleApp: App {
    var body: some Scene {
        WindowGroup {
            AppRouter()
                .preferredColorScheme(.dark)
                .statusBarHidden(false)
        }
    }
}
