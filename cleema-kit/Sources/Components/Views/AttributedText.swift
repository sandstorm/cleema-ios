//
//  Created by Kumpels and Friends on 13.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import SwiftUI

#if !os(macOS)

public struct AttributedText: View {
    @State private var size: CGSize = .zero
    let attributedString: NSAttributedString

    public init(_ attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }

    public var body: some View {
        AttributedTextRepresentable(attributedString: attributedString, size: $size)
        // .background(.red)
        //  .frame(width: size.width, height: size.height)
    }

    struct AttributedTextRepresentable: UIViewRepresentable {
        let attributedString: NSAttributedString
        @Binding var size: CGSize

        func makeUIView(context: Context) -> UILabel {
            let label = UILabel()

            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 0
            label.preferredMaxLayoutWidth = 320
            label.attributedText = attributedString

            return label
        }

        func updateUIView(_ uiView: UILabel, context: Context) {
            uiView.attributedText = attributedString

//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                size = uiView.sizeThatFits(uiView.superview?.bounds.size ?? .zero)
//            }
        }
    }
}

#endif
