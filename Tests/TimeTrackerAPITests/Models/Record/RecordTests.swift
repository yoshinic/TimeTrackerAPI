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
            let category = try await CategoryModel.query(on: dbm.db).first()
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
            on: dbm.db
        )

        let newRecord = try await RecordModel.create(
            .init(
                activityId: newActivity.id!,
                startedAt: Date(),
                endedAt: Date(),
                note: ""
            ),
            on: dbm.db
        )

        guard
            let found = try await RecordModel
            .fetch(
                .init(
                    id: newRecord.id!,
                    categories: [],
                    activities: [],
                    from: nil,
                    to: nil
                ),
                on: dbm.db
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

    func testToData() async throws {
        guard
            let category = try await CategoryModel.query(on: dbm.db).first()
        else { throw AppError.notFound }

        let name = "a"
        let color = "#000000"
        let activityService = ActivityService(db: dbm.db)
        let activity = try await activityService.create(
            categoryId: category.id!,
            name: name,
            color: color
        )

        let note = "zzz"
        let recordService = RecordService(db: dbm.db)
        let new = try await recordService.create(
            activityId: activity.id,
            startedAt: Date(),
            endedAt: Date(),
            note: note
        )

        XCTAssertTrue(
            new.note == note
                && new.activity?.name == name
                && new.activity?.category?.name == category.name
        )
    }
}
