@testable import TimeTrackerAPI
import XCTest

final class CategoryTests: AbstractionXCTestCase {
    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    func testCreate() async throws {
        let service: CategoryService = .init(db: dbm.database)

        let name = "sample"
        let color = "#FFFFFF"
        let new = try await service.create(name: name, color: color)

        guard
            let found = try await service.fetch(name: name, color: color).first
        else {
            return  XCTFail("")
        }

        XCTAssertTrue(new.name == found.name)
    }

    func testToData() async throws {
        let service: CategoryService = .init(db: dbm.database)

        let name = "sample"
        let color = "#FFFFFF"
        let new = try await service.create(name: name, color: color)

        guard
            let category = try await CategoryModel
            .create(
                .init(name: name, color: color, order: 10),
                on: dbm.database
            )
        else {
            XCTAssertThrowsError("invalid")
            return
        }

        let data = category.toData
        XCTAssertTrue(new.name == data.name && new.color == data.color)
    }
}
