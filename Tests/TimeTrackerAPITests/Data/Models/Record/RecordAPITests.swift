@testable import TimeTrackerAPI
import XCTest
import Foundation

final class RecordAPITests: AbstractionXCTestCase {
    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    func testCreate() async throws {
        try await migration { db in

            let activityName = "sample"

            let newActivity = try await ActivityModel.create(.init(name: activityName, color: "#000000"), on: db)

            let newRecord = try await RecordModel.create(
                .init(activityId: newActivity.id!, startedAt: Date(), endedAt: Date()),
                on: db
            )

            let founds = try await RecordModel
                .find(.init(recordId: newRecord.requireID(), activityId: newActivity.requireID()), on: db)

            guard founds.count == 1 else { return  XCTFail("") }

            let n = try founds[0].joined(ActivityModel.self).name

            XCTAssertTrue(n == activityName)
        }
    }
}
