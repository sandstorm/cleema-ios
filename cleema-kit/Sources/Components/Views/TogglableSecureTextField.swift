//
//  Created by Kumpels and Friends on 26.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import SwiftUI

public struct TogglableSecureTextField: View {
    @State private var showsAsPlainText = false
    var label: String
    @Binding var text: String
    var buttonColor: Color
    var buttonTrailingPadding: CGFloat = 0

    public init(label: String, text: Binding<String>, buttonColor: Color, buttonTrailingPadding: CGFloat = 0) {
        self.label = label
        _text = text
        self.buttonColor = buttonColor
        self.buttonTrailingPadding = buttonTrailingPadding
    }

    public var body: some View {
        HStack {
            ZStack {
                TextField(label, text: $text).hidden() // ensure same height

                if showsAsPlainText {
                    TextField(label, text: $text)
                } else {
                    SecureField(label, text: $text)
                }
            }

            Button {
                withAnimation {
                    showsAsPlainText.toggle()
                }
            } label: {
                Image(systemName: showsAsPlainText ? "eye" : "eye.slash")
            }
            .foregroundColor(buttonColor)
            .padding(.trailing, buttonTrailingPadding)
        }
    }
}

struct TogglableSecureTextField_Previews: PreviewProvider {
    private struct TogglableSecureTextFieldContainer: View {
        @State private var text: String = ""

        var body: some View {
            HStack {
                TogglableSecureTextField(label: "Password", text: $text, buttonColor: .lightGray)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }

    static var previews: some View {
        TogglableSecureTextFieldContainer()
            .padding()
    }
}
