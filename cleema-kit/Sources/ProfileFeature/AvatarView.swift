//
//  Created by Kumpels and Friends on 03.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models
import NukeUI
import SwiftUI

struct AvatarView: View {
    let avatar: IdentifiedImage?
    let isSupporter: Bool

    var body: some View {
        if let avatar = avatar {
            LazyImage(url: avatar.image.url) { state in
                if let image = state.image {
                    image
                        .resizingMode(.aspectFit)
                }
            }
            .frame(width: 104, height: 104)
            .clipShape(Circle())
            .overlay {
                if isSupporter {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 26))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.defaultText, Color.white)
                        .offset(x: 40, y: 30)
                }
            }
        } else {
            Image(systemName: "person.circle")
                .resizable()
                .font(.largeTitle)
                .frame(width: 104, height: 104)
        }
    }
}
