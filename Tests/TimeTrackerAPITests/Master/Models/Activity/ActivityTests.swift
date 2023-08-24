@testable import TimeTrackerAPI
import XCTest
import Foundation
import FluentKit

final class ActivityTests: AbstractionXCTestCase {
    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    func testCreate() async throws {
        try await migration { db in

            let name = "study"

            let newActivity = ActivityModel(name: name, color: "#000000")
            try await newActivity.create(on: db)

            guard
                let found = try await ActivityModel
                .query(on: db)
                .filter(\.$name == name)
                .first()
            else {
                return  XCTFail("")
            }

            XCTAssertTrue(found.name == name)
        }
    }
}
