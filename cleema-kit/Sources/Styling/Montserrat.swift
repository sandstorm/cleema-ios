//
//  Created by Kumpels and Friends on 09.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import SwiftUI

public enum Montserrat: String, CaseIterable {
    case regular = "Montserrat-Regular"
    case semibold = "Montserrat-SemiBold"
}

//
// public extension Font.TextStyle {
//    var size: CGFloat {
//        switch self {
//        case .largeTitle: return 60
//        case .title: return 48
//        case .title2: return 34
//        case .title3: return 24
//        case .headline, .body: return 18
//        case .subheadline, .callout: return 16
//        case .footnote: return 14
//        case .caption, .caption2: return 12
//        @unknown default:
//            return 8
//        }
//    }
// }

public extension Font {
    static func montserrat(style: Font.TextStyle, size: CGFloat) -> Self {
        .custom("Montserrat", size: size, relativeTo: style)
    }

    static func montserratBold(style: Font.TextStyle, size: CGFloat) -> Self {
        .montserrat(style: style, size: size).bold()
    }
}

#if canImport(UIKit)
import UIKit

public extension UIFont {
    static func montserrat(style: UIFont.TextStyle = .body, size: CGFloat) -> UIFont {
        UIFont(name: Montserrat.regular.rawValue, size: size)!.dynamicallyTyped(withStyle: style)
    }

    static func montserratBold(style: UIFont.TextStyle = .body, size: CGFloat) -> UIFont {
        UIFont(name: Montserrat.semibold.rawValue, size: size)!.bold().dynamicallyTyped(withStyle: style)
    }

    func dynamicallyTyped(withStyle style: UIFont.TextStyle) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        return metrics.scaledFont(for: self)
    }
}

extension UIFont {
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0)
    }

    func bold() -> UIFont {
        withTraits(traits: .traitBold)
    }

    func italic() -> UIFont {
        withTraits(traits: .traitItalic)
    }
}
#endif
