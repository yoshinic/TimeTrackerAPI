@testable import TimeTrackerAPI
import XCTest

final class RecordTests: AbstractionXCTestCase {
    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    func testCreate() async throws {
        try await migration { db in
            let name = "sample"
            let newActivity = try await ActivityModel.create(
                .init(name: name, color: "#000000", order: 1),
                on: db
            )

            let newRecord = try await RecordModel.create(
                .init(activityId: newActivity.id!, startedAt: Date(), endedAt: Date()),
                on: db
            )

            guard
                let found = try await RecordModel
                .fetch(
                    .init(
                        recordId: newRecord.id!,
                        from: nil,
                        to: nil,
                        activityIds: [],
                        activityNames: [],
                        activityColors: []
                    ),
                    on: db
                )
                .first
            else {
                return  XCTFail("")
            }

            let foundActivity = try found.joined(ActivityModel.self)
            XCTAssertTrue(newRecord.$activity.id == foundActivity.id)
            XCTAssertTrue(newRecord.startedAt == found.startedAt)
            XCTAssertTrue(newRecord.endedAt == found.endedAt)
        }
    }
}
