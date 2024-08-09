//
//  Created by Kumpels and Friends on 29.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

@testable import DeepLinking
import XCTest

final class AppRouterTests: XCTestCase {
    func testDeepLinking() throws {
        var result = try appRouter.match(url: URL(string: "/invites/cleema-coda")!)
        XCTAssertEqual(AppRoute.invitation("cleema-coda"), result)

        result = try appRouter.match(url: URL(string: "/become-sponsor/")!)
        XCTAssertEqual(AppRoute.becomeSponsor, result)

        let uuid = UUID()
        result = try appRouter.match(url: URL(string: "/become-sponsor/\(uuid)")!)
        XCTAssertEqual(AppRoute.becomeSponsorForUserWithID(uuid), result)
    }
}
