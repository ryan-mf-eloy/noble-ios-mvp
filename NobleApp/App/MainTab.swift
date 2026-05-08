import SwiftUI

enum MainTab: Hashable {
    case home, market, activity, profile

    var title: String {
        switch self {
        case .home:     "Home"
        case .market:   "Market"
        case .activity: "Activity"
        case .profile:  "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home:     "house"
        case .market:   "bag"
        case .activity: "bell"
        case .profile:  "person"
        }
    }
}
