//
//  Created by Kumpels and Friends on 19.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Components
import Foundation
import XCTest

final class EmailValidatorTests: XCTestCase {
    func testInvalidMails() {
        let validator = EmailValidator.live

        XCTAssertNil(validator.validate(""))
        XCTAssertNil(validator.validate("     "))
        XCTAssertNil(validator.validate("hi"))
        XCTAssertNil(validator.validate("@test.de"))
        XCTAssertNil(validator.validate("test@.de"))
        XCTAssertNil(validator.validate("hi@there,com"))
    }

    func testMails() {
        let validator = EmailValidator.live

        XCTAssertEqual("hi@there.com", validator.validate("hi@there.com"))
        XCTAssertEqual("hi@there.com", validator.validate("   hi@there.com  "))
        XCTAssertEqual("123@127.0.0.1", validator.validate("123@127.0.0.1"))
        XCTAssertEqual("mail_with@domäin.com", validator.validate("mail_with@domäin.com"))
    }
}
