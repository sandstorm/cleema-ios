//
//  Created by Kumpels and Friends on 20.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Fakes
import Foundation
import Tagged

public extension Partner {
    static func fake(
        id: Partner.ID = .init(rawValue: .init()),
        title: String = .word(),
        url: URL = [
            URL(string: "https://dresden.de")!,
            URL(string: "https://leipzig.de")!,
            URL(string: "https://doebeln.de")!
        ].randomElement()!,
        description: String = .sentence(),
        logo: RemoteImage? = .fake(width: 300, height: 108)
    ) -> Self {
        .init(
            id: id,
            title: title,
            url: url,
            description: description,
            logo: logo
        )
    }
}
