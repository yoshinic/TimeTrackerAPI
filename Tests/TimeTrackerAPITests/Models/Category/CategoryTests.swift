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
        let service: CategoryService = .init(db: dbm.db)

        let name = "sample"
        let color = "#FFFFFF"
        let new = try await service.create(
            name: name,
            color: color,
            icon: ""
        )

        let found = try await service.fetch(name: name).first

        XCTAssertTrue(new?.name == found?.name)
    }

    func testToData() async throws {
        let service: CategoryService = .init(db: dbm.db)

        let name = "sample"
        let color = "#FFFFFF"

        guard
            let new = try await service.create(
                name: name,
                color: color,
                icon: ""
            )
        else {
            return  XCTFail("")
        }

        let category = try await CategoryModel
            .create(
                .init(
                    name: name,
                    color: color,
                    icon: "",
                    order: 10
                ),
                on: dbm.db
            )

        let data = category.toData
        XCTAssertTrue(new.name == data.name && new.color == data.color)
    }
}
