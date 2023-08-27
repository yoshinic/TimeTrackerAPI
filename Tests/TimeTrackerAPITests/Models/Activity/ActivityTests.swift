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
        let name = "study"
        let newActivity = try await ActivityModel.create(
            .init(id: UUID(), name: name, color: "#000000", order: 1),
            on: dbm.database
        )

        guard
            let found = try await ActivityModel
            .fetch(.init(id: nil, name: name, color: nil), on: dbm.database)
            .first
        else {
            return  XCTFail("")
        }

        XCTAssertTrue(newActivity.name == found.name)
        XCTAssertTrue(newActivity.color == found.color)
    }
}
