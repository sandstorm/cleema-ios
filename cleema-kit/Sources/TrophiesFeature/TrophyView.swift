//
//  Created by Kumpels and Friends on 11.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import Models
import NukeUI
import SwiftUI

struct TrophyView: View {
    var trophy: Trophy

    var body: some View {
        Components.TrophyView(title: trophy.title, date: trophy.date, image: trophy.image)
    }
}

struct TrophyView_Previews: PreviewProvider {
    static var previews: some View {
        TrophyView(trophy: .init(
            date: .now,
            title: "Erste Umfrage: Check.",
            image: .fake(width: 104, height: 104)
        ))
        .cleemaStyle()
    }
}
