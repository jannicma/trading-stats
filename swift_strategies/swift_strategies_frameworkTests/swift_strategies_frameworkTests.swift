//
//  swift_strategies_frameworkTests.swift
//  swift_strategies_frameworkTests
//
//  Created by Jannic Marcon on 27.07.2025.
//

import Testing
@testable import swift_strategies_framework

struct swift_strategies_frameworkTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        var defStruct = Def()
        var retVal = defStruct.test()
        #expect(retVal == "Def")
    }

}
