//
//  Created by Kumpels and Friends on 11.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import SwiftUI

struct TrophyDialogView: View {
    var trophy: Trophy
    @State private var confettiCounter = 0

    var body: some View {
        Button {
            confettiCounter += 1
        } label: {
            TrophyView(title: trophy.title, date: trophy.date, image: trophy.image)
                .confettiCannon(
                    counter: $confettiCounter,
                    num: 50,
                    confettis: [.shape(.circle)],
                    colors: [.action, .answer, .defaultText, .selfChallenge],
                    openingAngle: Angle(degrees: 0),
                    closingAngle: Angle(degrees: 360),
                    radius: 200
                )
        }
        .task {
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
            confettiCounter += 1
        }
    }
}

struct TrophyDialogView_Previews: PreviewProvider {
    static var previews: some View {
        TrophyDialogView(trophy: .fake())
    }
}
