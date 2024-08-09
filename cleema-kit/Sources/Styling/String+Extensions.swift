//
//  Created by Kumpels and Friends on 13.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import SwiftUI

public extension String {
    func attributedText(
        style: UIFont.TextStyle = .body,
        size: CGFloat = 16,
        textColor: UIColor = .defaultText
    ) -> AttributedString {
        var attr = AttributedString(self)
        var container = AttributeContainer()
        container[AttributeScopes.UIKitAttributes.ForegroundColorAttribute.self] = textColor
        container[AttributeScopes.UIKitAttributes.FontAttribute.self] = UIFont.montserrat(style: style, size: size)
        attr.mergeAttributes(container, mergePolicy: .keepNew)
        return attr
    }
}
