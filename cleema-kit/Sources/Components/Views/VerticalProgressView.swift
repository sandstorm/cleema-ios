//
//  Created by Kumpels and Friends on 01.08.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import SwiftUI

public struct VerticalProgressView<V: BinaryFloatingPoint, CurrentValueLabel: View>: View {
    public var value: V?
    public var total: V = 1.0
    public var currentValueLabel: CurrentValueLabel

    @State private var progressHeight: CGFloat = 0
    @State private var currentLabelHeight: CGFloat = 0

    public init(value: V?, total: V = 1.0, @ViewBuilder currentValueLabel: () -> CurrentValueLabel) {
        self.value = value
        self.total = total
        self.currentValueLabel = currentValueLabel()
    }

    public init(value: V?, total: V = 1.0) where CurrentValueLabel == EmptyView {
        self.value = value
        self.total = total
        currentValueLabel = EmptyView()
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            currentValueLabel
                .foregroundColor(.accentColor)
                .reportSize(CurrentValueLabelID.self) {
                    currentLabelHeight = $0.height
                }
                .alignmentGuide(VerticalAlignment.bottom) { _ in
                    CGFloat((value ?? 0) / total) * progressHeight + currentLabelHeight / 2
                }

            ZStack(alignment: .bottom) {
                Capsule(style: .continuous)
                    .foregroundColor(.white)
                    .reportSize(ValueProgressID.self) {
                        progressHeight = $0.height
                    }

                Capsule(style: .continuous)
                    .foregroundColor(.accentColor)
                    .frame(height: CGFloat((value ?? 0) / total) * progressHeight)
            }
            .frame(width: 8)
        }
    }

    private enum CurrentValueLabelID {}
    private enum ValueProgressID {}
}

struct VerticalProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VerticalProgressView(value: Double.random(in: 0 ..< 1))
            .frame(width: 200, height: 200)
            .padding()
            .background(.gray)
    }
}
