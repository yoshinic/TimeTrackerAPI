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
        guard
            let category = try await CategoryModel.query(on: dbm.database).first()
        else { throw AppError.notFound }
        
        let name = "sample"
        let newActivity = try await ActivityModel.create(
            .init(
                id: UUID(),
                categoryId: category.id!,
                name: name,
                color: "#000000",
                order: 1
            ),
            on: dbm.database
        )

        let newRecord = try await RecordModel.create(
            .init(
                activityId: newActivity.id!,
                startedAt: Date(),
                endedAt: Date(),
                note: ""
            ),
            on: dbm.database
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
                on: dbm.database
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
