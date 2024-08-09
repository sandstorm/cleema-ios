//
//  Created by Kumpels and Friends on 01.08.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Models
import Styling
import SwiftUI

public struct TagView: View {
    var tag: Tag

    public init(tag: Tag) {
        self.tag = tag
    }

    public var body: some View {
        Text("#\(tag.value)")
            .font(.montserrat(style: .footnote, size: 12))
            .foregroundColor(.action)
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView(tag: .fake())
            .padding()
            .background(.gray)
    }
}
