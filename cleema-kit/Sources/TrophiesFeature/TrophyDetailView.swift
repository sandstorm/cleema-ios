//
//  Created by Kumpels and Friends on 05.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ConfettiSwiftUI
import Models
import Styling
import SwiftUI

struct TrophyDetailView: View {
    var trophy: Trophy

    @State private var counter: Int = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Button {
                counter += 1
            } label: {
                TrophyView(trophy: trophy)
                    .scaleEffect(2)
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 208)
                    .cardShadow()
            }
            .confettiCannon(
                counter: $counter,
                num: 50,
                confettis: [.shape(.circle)],
                colors: [.action, .answer, .defaultText, .selfChallenge],
                openingAngle: Angle(degrees: 0),
                closingAngle: Angle(degrees: 360),
                radius: 200
            )
            VStack {
                Text(L10n.Trophy.Received.label)
                Text(trophy.date, style: .date)
                    .font(.montserrat(style: .body, size: 16))
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.accent, ignoresSafeAreaEdges: .all)
        .navigationTitle(L10n.Trophy.Detail.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TrophyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TrophyDetailView(trophy: .init(
            date: .now,
            title: "Erste Umfrage: Check.",
            image: .fake(width: 104, height: 104)
        ))
        .cleemaStyle()
    }
}
