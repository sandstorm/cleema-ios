//
//  Created by Kumpels and Friends on 11.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Styling
import SwiftUI

struct PersonsJoinedView: View {
    var count: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "person.3.fill")
            Text(L10n.numberOfUsers(count))
                .font(.montserrat(style: .footnote, size: 12))
        }
    }
}

struct PersonsJoinedView_Previews: PreviewProvider {
    static var previews: some View {
        PersonsJoinedView(count: 12)
    }
}
