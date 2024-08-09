//
//  Created by Kumpels and Friends on 24.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import MainFeature
import MarkdownUI
import Styling
import SwiftUI

@main
struct CleemaApp: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            if CleemaApp.isTesting {
                ZStack {
                    Color.red
                    Text("Running tests...")
                        .foregroundColor(.white)
                }
                .ignoresSafeArea()
            } else {
                MainView(store: liveStore)
                    .font(.montserrat(style: .body, size: 16))
                    .groupBoxStyle(.plain)
                    .markdownStyle(
                        MarkdownStyle(
                            font: .custom("Montserrat", size: 16),
                            foregroundColor: .defaultText
                        )
                    )
            }
        }
    }
}

extension CleemaApp {
    static var isTesting: Bool {
        UserDefaults.standard.bool(forKey: "isTesting")
    }
}
