//
//  Created by Kumpels and Friends on 27.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models
import NukeUI
import Styling
import SwiftUI

struct ProjectView: View {
    var project: Project

    var body: some View {
        VStack {
            if let teaserImage = project.teaserImage {
                LazyImage(url: teaserImage.url, resizingMode: .aspectFit)
                    .frame(width: teaserImage.width, height: teaserImage.height)
            }

            Text(project.title)
                .font(.montserrat(style: .title, size: 14))
            Text(project.partner.title)
                .font(.montserrat(style: .footnote, size: 12))
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .aspectRatio(1, contentMode: .fit)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .foregroundColor(.dimmed)
        )
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectView(project: .fake(title: "Project A"))
    }
}
