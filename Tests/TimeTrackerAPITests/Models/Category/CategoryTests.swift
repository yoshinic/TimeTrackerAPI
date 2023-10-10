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

        try await service.delete()

        let name = "語学"
        let color = "#FFFFFF"
        let new = try await service.create(name: name, color: color)

        guard
            let found = try await service.fetch(name: name, color: color).first
        else {
            return  XCTFail("")
        }

        XCTAssertTrue(new.name == found.name)
    }
}
