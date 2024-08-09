//
//  Created by Kumpels and Friends on 23.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import SwiftUI

public struct ErrorHintView: View {
    var message: String
    var dismissAction: () -> Void

    public init(message: String, dismissAction: @escaping () -> Void) {
        self.message = message
        self.dismissAction = dismissAction
    }

    public var body: some View {
        Text(message)
            .foregroundColor(.action)
            .font(.montserrat(style: .body, size: 14))
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(3)
            .padding(8)
            .padding(.trailing, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.white)
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.action, lineWidth: 2)
                }
            )
            .overlay(alignment: .trailingFirstTextBaseline) {
                Button {
                    dismissAction()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.medium)
                }
                .foregroundColor(.action)
                .padding(6)
            }
    }
}

struct ErrorHintView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorHintView(
            message: "All your base are belong to us",
            dismissAction: {}
        )
        .padding()
    }
}
