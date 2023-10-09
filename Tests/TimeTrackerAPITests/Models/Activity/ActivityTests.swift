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

    func testMove() async throws {
        let n1 = "a"
        let o1 = 1
        try await ActivityModel.create(
            .init(id: UUID(), name: n1, color: "#000000", order: 1),
            on: dbm.database
        )

        let n2 = "b"
        let o2 = 2
        try await ActivityModel.create(
            .init(id: UUID(), name: n2, color: "#000000", order: 2),
            on: dbm.database
        )

        let founds = try await ActivityModel.fetch(on: dbm.database)

        guard founds.count == 2 else { return  XCTFail("") }

        XCTAssertTrue(founds[0].name == n1 && founds[0].order == o1)
        XCTAssertTrue(founds[1].name == n2 && founds[1].order == o2)

        // move
        let service = ActivityService(db: dbm.database)
        try await service.move(ids: [founds[1].id!, founds[0].id!])

        let moved = try await ActivityModel.fetch(on: dbm.database)

        XCTAssertTrue(moved[0].name == n2 && moved[0].order == o1)
        XCTAssertTrue(moved[1].name == n1 && moved[1].order == o2)
    }
}
