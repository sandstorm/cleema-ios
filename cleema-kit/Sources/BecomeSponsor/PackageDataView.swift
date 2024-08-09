//
//  Created by Kumpels and Friends on 26.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Models
import SwiftUI

struct PackageDataView: View {
    var package: SponsorPackage

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top, spacing: 16) {
                package.symbol
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 36, maxHeight: 36)
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().foregroundColor(.defaultText))
                VStack(alignment: .leading, spacing: 4) {
                    Text("cleema")
                        .font(.montserratBold(style: .title, size: 22))
                        .foregroundColor(.defaultText) +
                        Text(package.title)
                        .font(.montserratBold(style: .title, size: 24))
                        .foregroundColor(.dimmed)

                    Text(package.copy)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.montserrat(style: .body, size: 16))
                        .lineLimit(2)
                        .foregroundColor(.defaultText)
                }
            }
            Asset.priceTag.image
                .resizable()
                .scaledToFit()
                .overlay {
                    Text("\(package.priceInEuro),- EUR im Monat")
                        .font(.montserratBold(style: .body, size: 16))
                        .foregroundColor(.white)
                }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PackageDataView(package: .fan)
            .frame(width: 375, height: 200)
            .padding()
            .cleemaStyle()
    }
}
