//
//  Created by Kumpels and Friends on 10.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Models
import NukeUI
import Styling
import SwiftUI

@MainActor
public struct DialogView<ImageContent: View>: View {
    public struct DialogButton {
        var title: String
        var action: () -> Void

        public init(title: String, action: @escaping () -> Void) {
            self.title = title
            self.action = action
        }
    }

    public init(
        title: String,
        message: String? = nil,
        @ViewBuilder image: @escaping () -> ImageContent,
        defaultButton: DialogButton,
        closeButton: DialogButton? = nil
    ) {
        self.title = title
        self.image = image()
        self.message = message
        self.defaultButton = defaultButton
        self.closeButton = closeButton
    }

    var title: String
    var image: ImageContent?
    var message: String?

    var defaultButton: DialogButton
    var closeButton: DialogButton?

    public var body: some View {
        ZStack {
            VStack(spacing: 24) {
                HStack(alignment: .top) {
                    if closeButton != nil {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.large)
                            .hidden()
                    }

                    Spacer()

                    Text(title)
                        .font(.montserratBold(style: .largeTitle, size: 22))

                    Spacer()

                    if let closeButton {
                        Button {
                            closeButton.action()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                        }
                        .foregroundColor(.gray.opacity(0.5))
                        .frame(alignment: .trailing)
                    }
                }

                VStack(spacing: 14) {
                    if let image {
                        image
                            .frame(width: 104, height: 104)
                    }
                    if let message {
                        Text(message)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.bottom)

                Button(defaultButton.title) {
                    defaultButton.action()
                }
                .buttonStyle(.action(maxWidth: .infinity))
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.white)
            }
            .cardShadow()
            .padding()
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Rectangle()
                .fill(
                    RadialGradient(gradient: Gradient(colors: [
                        .black.opacity(0.5), .black.opacity(0.7)
                    ]), center: .center, startRadius: 0, endRadius: 400)
                )
                .ignoresSafeArea()
                .onTapGesture {
                    if let closeButton {
                        closeButton.action()
                    }
                }
        )
    }
}

public extension DialogView where ImageContent == LazyImage<NukeUI.Image?> {
    init(
        title: String,
        remoteImage: RemoteImage,
        message: String? = nil,
        defaultButton: DialogButton,
        closeButton: DialogButton? = nil
    ) {
        self.init(
            title: title,
            message: message,
            image: {
                LazyImage(url: remoteImage.url) { state in
                    if let image = state.image {
                        image
                            .resizingMode(.aspectFit)
                    }
                }
            },
            defaultButton: defaultButton,
            closeButton: closeButton
        )
    }
}

public extension DialogView where ImageContent == EmptyView {
    init(
        title: String,
        message: String? = nil,
        defaultButton: DialogButton,
        closeButton: DialogButton? = nil
    ) {
        self.title = title
        image = nil
        self.message = message
        self.defaultButton = defaultButton
        self.closeButton = closeButton
    }
}

struct DialogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HStack {
                Spacer()
                Text("Hello World")
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .overlay {
                DialogView(
                    title: "Congratulation",
                    message: "mmlr is your new friend",
                    image: { EmptyView() },
                    defaultButton: .init(title: "Dismiss", action: {}),
                    closeButton: .init(title: "", action: {})
                )
            }
        }
        .cleemaStyle()
    }
}
