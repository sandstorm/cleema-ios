//
//  Created by Kumpels and Friends on 12.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

@testable import APIClient
import XCTest

final class LocationTests: XCTestCase {
    func testLocationInitializesWithValidRawValues() throws {
        let rawValue = LocationResponse(title: "Foo", coordinates: .init(latitude: 50, longitude: 12))

        let sut = Location(rawValue: rawValue)

        XCTAssertNotNil(sut)
    }

    func testLocationInitializesWithInvalidLatitudeIsNil() throws {
        let rawValue = LocationResponse(title: "Foo", coordinates: .init(latitude: 50_000, longitude: 12))

        let sut = Location(rawValue: rawValue)

        XCTAssertNil(sut)
    }

    func testLocationInitializesWithInvalidLongitudeIsNil() throws {
        let rawValue = LocationResponse(title: "Foo", coordinates: .init(latitude: 50, longitude: 12_000))

        let sut = Location(rawValue: rawValue)

        XCTAssertNil(sut)
    }
}
