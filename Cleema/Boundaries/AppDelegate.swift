//
//  Created by Kumpels and Friends on 08.09.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Styling
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        guard !CleemaApp.isTesting else { return true }
        Styling.configureApp()
        #if DEBUG
        UserDefaults.standard.executeLaunchArguments()
        #endif
        return true
    }
}
