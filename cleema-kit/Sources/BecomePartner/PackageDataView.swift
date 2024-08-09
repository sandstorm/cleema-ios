//
//  Created by Kumpels and Friends on 27.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Models
import SwiftUI

struct PackageDataView: View {
    var package: PartnerPackage

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
                        .font(.montserratBold(style: .title, size: 18))
                        .foregroundColor(.defaultText) +
                        Text(package.title)
                        .font(.montserratBold(style: .title, size: 18))
                        .foregroundColor(.dimmed)

                    Text(package.copy)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.montserrat(style: .body, size: 18))
                        .lineLimit(2)
                        .foregroundColor(.defaultText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .minimumScaleFactor(0.25)
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PackageDataView(package: .darling)
            .frame(width: 375, height: 200)
            .padding()
            .background(Color.accent)
            .cleemaStyle()
    }
}
