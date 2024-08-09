//
//  Created by Kumpels and Friends on 26.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import NukeUI
import SwiftUI

struct AvatarDialogView: View {
    var avatar: RemoteImage?

    var body: some View {
        if let avatar {
            LazyImage(url: avatar.url) { state in
                if let image = state.image {
                    image
                        .resizingMode(.aspectFit)
                }
            }
            .frame(width: 104, height: 104)
            .clipShape(Circle())
        } else {
            Image(systemName: "person.circle")
                .resizable()
                .foregroundColor(.defaultText)
                .frame(width: 104, height: 104)
        }
    }
}

struct AvatarDialogView_Previews: PreviewProvider {
    static var previews: some View {
        TrophyDialogView(trophy: .fake())
    }
}
