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
        guard
            let category = try await CategoryModel.query(on: dbm.database).first()
        else { throw AppError.notFound }

        let name = "study"
        let newActivity = try await ActivityModel.create(
            .init(id: UUID(), categoryId: category.id!, name: name, color: "#000000", order: 1),
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
        guard
            let category = try await CategoryModel.query(on: dbm.database).first()
        else { throw AppError.notFound }

        let a = try await ActivityModel.fetch(on: dbm.database)

        let n1 = "sample1"
        let o1 = 1
        let new1 = try await ActivityModel.create(
            .init(
                id: UUID(),
                categoryId: category.id!,
                name: n1,
                color: "#000000",
                order: o1
            ),
            on: dbm.database
        )

        let n2 = "sample2"
        let o2 = 2
        let new2 = try await ActivityModel.create(
            .init(
                id: UUID(),
                categoryId: category.id!,
                name: n2,
                color: "#000000",
                order: o2
            ),
            on: dbm.database
        )

        let founds = try await ActivityModel.fetch(on: dbm.database)

        guard founds.count - a.count == 2 else { return  XCTFail("") }
        guard
            let found1 = founds.first(where: { $0.id == new1.id }),
            let found2 = founds.first(where: { $0.id == new2.id })
        else { return  XCTFail("")  }

        XCTAssertTrue(found1.name == n1 && found1.order == o1)
        XCTAssertTrue(found2.name == n2 && found2.order == o2)

        // move
        let service = ActivityService(db: dbm.database)
        try await service.updateOrder(ids: [founds[1].id!, founds[0].id!])

        let moved = try await ActivityModel.fetch(on: dbm.database)
        guard
            let moved1 = moved.first(where: { $0.id == new1.id }),
            let moved2 = moved.first(where: { $0.id == new2.id })
        else { return  XCTFail("")  }
        
        XCTAssertTrue(moved1.name == n2 && moved1.order == o1)
        XCTAssertTrue(moved2.name == n1 && moved2.order == o2)
    }

    func testToData() async throws {
        guard
            let category = try await CategoryModel.query(on: dbm.database).first()
        else { throw AppError.notFound }

        let name = "a"
        let color = "#000000"
        let service = ActivityService(db: dbm.database)
        let new = try await service.create(
            categoryId: category.id!,
            name: name,
            color: color
        )

        XCTAssertTrue(
            new.name == name
                && new.color == color
                && new.category.name == category.name
        )
    }

    func testFetchEagerLoad() async throws {
        guard
            let category = try await CategoryModel.query(on: dbm.database).first()
        else { throw AppError.notFound }

        let a = try await ActivityModel
            .fetch(.init(categoryId: category.id!), on: dbm.database)

        let name = "sample"
        let color = "#000000"
        try await ActivityModel.create(
            .init(
                categoryId: category.id!,
                name: name,
                color: color,
                order: 1
            ),
            on: dbm.database
        )

        let found = try await ActivityModel
            .fetch(.init(categoryId: category.id!), on: dbm.database)

        XCTAssertTrue(found.count - a.count == 1)
        XCTAssertTrue(found[0].$category.wrappedValue.name == category.name)
    }
}
