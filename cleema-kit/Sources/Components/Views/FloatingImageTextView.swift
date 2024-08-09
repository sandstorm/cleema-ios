//
//  Created by Kumpels and Friends on 13.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import SwiftUI

public struct FloatingImageTextView: View {
    var text: AttributedString
    var image: Image?
    @State private var imageSize: CGSize = .zero

    public init(text: AttributedString, image: Image?) {
        self.text = text
        self.image = image
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            ExclusionTextView(text: text) { textView in
                guard imageSize != .zero, image != nil else { return }
                textView.textContainer.exclusionPaths = [
                    UIBezierPath(rect: .init(
                        origin: .init(x: textView.bounds.width - imageSize.width, y: 0),
                        size: imageSize
                    ))
                ]
            }
            image
                .padding(4)
                .reportSize(FloatingImageTextView.self) {
                    imageSize = $0
                }
        }
    }
}

struct ExclusionTextView: View {
    var text: AttributedString
    var configuration: (UITextView) -> Void
    @State private var height: CGFloat = 0

    init(text: AttributedString, configuration: @escaping (UITextView) -> Void = { _ in }) {
        self.text = text
        self.configuration = configuration
    }

    var body: some View {
        ExclusionTextViewRepresentable(text: text, height: $height, configuration: configuration)
            .frame(height: height)
    }

    struct ExclusionTextViewRepresentable: UIViewRepresentable {
        var text: AttributedString
        @Binding var height: CGFloat
        var configuration = { (view: UITextView) in }

        func makeUIView(context _: Context) -> UITextView {
            let textView = UITextView()

            textView.attributedText = NSAttributedString(text)
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.backgroundColor = .clear
            textView.textContainerInset = UIEdgeInsets.zero
            textView.isSelectable = false
            textView.textContainer.lineFragmentPadding = 0
            textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            return textView
        }

        func updateUIView(_ uiView: UITextView, context _: Context) {
            uiView.attributedText = NSAttributedString(text)
            configuration(uiView)

            // Compute the desired height for the content
            let fixedWidth = uiView.frame.size.width
            let newSize = uiView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))

            DispatchQueue.main.async {
                self.height = newSize.height
            }
        }
    }
}
