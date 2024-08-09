//
//  Created by Kumpels and Friends on 27.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Styling
import SwiftUI

struct PersonsJoinedView: View {
    var count: Int
    var hasJoined: Bool
    var totalNeeded: Int?

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "person.3.fill")
            Text(text)
                .font(.montserrat(style: .footnote, size: 12))
        }
    }

    var text: String {
        if let totalNeeded = totalNeeded {
            if hasJoined {
                return L10n.Involvement.Summary.HasTotal.joined(count - 1, totalNeeded)
            } else {
                return L10n.Involvement.Summary.hasTotal(count, totalNeeded)
            }
        } else {
            if hasJoined {
                return L10n.Involvement.Summary.joined(count)
            } else {
                return L10n.Involvement.summary(count)
            }
        }
    }
}

struct PersonsJoinedView_Previews: PreviewProvider {
    static var previews: some View {
        PersonsJoinedView(count: 12, hasJoined: true, totalNeeded: 24)
    }
}
