//
//  Created by Kumpels and Friends on 23.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import SwiftUI

public extension Color {
    static let defaultText: Self = .init("defaultText", bundle: .module)
    static let dimmed: Self = .init("dimmed", bundle: .module)
    static let light: Self = .init("light", bundle: .module)
    static let textInput: Self = .init("textInput", bundle: .module)
    static let action: Self = .init("action", bundle: .module)
    static let accent: Self = .init("AccentColor", bundle: .module)
    static let answer: Self = .init("answer", bundle: .module)
    static let finishedProject: Self = .init("answer", bundle: .module)
    static let lightGray: Self = .init("lightGray", bundle: .module)

    static let recessedText: Self = .white.opacity(0.35)

    static let selfChallenge: Self = .init("selfChallenge", bundle: .module)
    static let partnerChallenge: Self = .init("partnerChallenge", bundle: .module)
    static let groupChallenge: Self = .action
    static let mobiChallenge: Self = .dimmed

    static let news: Self = .partnerChallenge
    static let tip: Self = .action

    static let redeemedVoucher: Self = .partnerChallenge
}
