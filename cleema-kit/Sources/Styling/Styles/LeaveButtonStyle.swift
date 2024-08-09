//
//  File.swift
//  
//
//  Created by Justin on 08.05.24.
//

import SwiftUI

public struct LeaveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        let backgroundColor: Color = Color.dimmed

        HStack {
            configuration.label
                .font(.montserratBold(style: .headline, size: 14))

            Spacer()

            //Image(systemName: "chevron.right")
        }
        .foregroundColor(.white)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(backgroundColor)
                .blendMode(configuration.isPressed ? .multiply : .normal)
        }
    }
}

public extension ButtonStyle where Self == LeaveButtonStyle {
    static var leave: Self { .init() }
}

