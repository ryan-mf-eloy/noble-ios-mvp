import SwiftUI

extension Color {
    // MARK: Brand
    static let nobleOrange = Color(hex: 0xFF4F1F)
    static let nobleYellow = Color(hex: 0xFFB800)

    // MARK: Surfaces
    static let nobleBlack = Color(hex: 0x0A0A0A)
    static let nobleSurface = Color(hex: 0x141414)
    static let nobleElevated = Color(hex: 0x1F1F1F)
    static let nobleBorder = Color(hex: 0x2A2A2A)

    // MARK: Text
    static let nobleTextPrimary = Color.white
    static let nobleMuted = Color(hex: 0x888888)

    // MARK: Semantic
    static let nobleSuccess = Color(hex: 0x00D26A)
    static let nobleLive = Color(hex: 0xFF1744)
    static let nobleVerified = Color(hex: 0x0095F6)
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
