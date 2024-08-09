//
//  Created by Kumpels and Friends on 25.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(UIKit) && !os(watchOS)
import UIKit

@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct ActivityView: UIViewControllerRepresentable {
    public var activityItems: [Any]
    public var applicationActivities: [UIActivity]?

    public init(activityItems: [Any], applicationActivities: [UIActivity]? = nil) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>)
        -> UIActivityViewController
    {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }

    public func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityView>
    ) {}
}

#if DEBUG
@available(tvOS, unavailable)
struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(activityItems: [URL(string: "https://kf-interactive.com")!])
    }
}
#endif

#endif
