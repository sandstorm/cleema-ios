//
//  Created by Kumpels and Friends on 09.08.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public extension UIColor {
    static let defaultText: UIColor = .init(named: "defaultText", in: .module, compatibleWith: nil)!
    static let dimmed: UIColor = .init(named: "dimmed", in: .module, compatibleWith: nil)!
    static let light: UIColor = .init(named: "light", in: .module, compatibleWith: nil)!
    static let textInput: UIColor = .init(named: "textInput", in: .module, compatibleWith: nil)!
    static let action: UIColor = .init(named: "action", in: .module, compatibleWith: nil)!
    static let accent: UIColor = .init(named: "AccentColor", in: .module, compatibleWith: nil)!

    static let selfChallenge: UIColor = .init(named: "selfChallenge", in: .module, compatibleWith: nil)!
    static let partnerChallenge: UIColor = .init(named: "partnerChallenge", in: .module, compatibleWith: nil)!
    static let groupChallenge: UIColor = .action
    static let mobiChallenge: UIColor = .dimmed
}
#endif
