import SwiftUI

enum FontFamily {
    static let anton = "Anton-Regular"
    static let inter = "Inter"
    static let caveat = "Caveat"
    static let mono = "JetBrainsMono-Bold"
}

enum InterWeight {
    case regular, medium, bold, black

    var fontWeight: Font.Weight {
        switch self {
        case .regular: .regular
        case .medium:  .medium
        case .bold:    .bold
        case .black:   .black
        }
    }
}

extension Font {
    static func druk(_ size: CGFloat) -> Font {
        .custom(FontFamily.anton, size: size)
    }

    static func inter(_ size: CGFloat, weight: InterWeight = .regular) -> Font {
        .custom(FontFamily.inter, size: size).weight(weight.fontWeight)
    }

    static func caveat(_ size: CGFloat) -> Font {
        .custom(FontFamily.caveat, size: size).weight(.bold)
    }

    static func mono(_ size: CGFloat) -> Font {
        .custom(FontFamily.mono, size: size)
    }
}
