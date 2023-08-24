@testable import TimeTrackerAPI
import XCTest
import Foundation
import FluentKit

final class RecordTests: AbstractionXCTestCase {
    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    func testCreate() async throws {
        try await migration { db in

            let activityName = "sample"

            let newActivity = ActivityModel(name: activityName,color: "#000000")
            try await newActivity.create(on: db)

            let newRecord = RecordModel(activityId: newActivity.id!, startedAt: Date(), endedAt: Date())
            try await newRecord.create(on: db)

            guard
                let found = try await RecordModel
                .query(on: db)
                .join(parent: \.$activity)
                .first()
            else {
                return  XCTFail("")
            }

            let n = try found.joined(ActivityModel.self).name

            XCTAssertTrue(n == activityName)
        }
    }
}
