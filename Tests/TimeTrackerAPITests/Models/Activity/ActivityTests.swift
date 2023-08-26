@testable import TimeTrackerAPI
import XCTest

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
            let newActivity = try await ActivityModel.create(.init(name: name, color: "#000000"), on: db)

            guard
                let found = try await ActivityModel
                .fetch(.init(id: nil, name: name, color: nil), on: db)
                .first
            else {
                return  XCTFail("")
            }

            XCTAssertTrue(newActivity.name == found.name)
            XCTAssertTrue(newActivity.color == found.color)
        }
    }
}
