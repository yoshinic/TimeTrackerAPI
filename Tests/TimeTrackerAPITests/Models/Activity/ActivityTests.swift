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
            let category = try await CategoryModel.query(on: dbm.db).first()
        else { throw AppError.notFound }

        let id = UUID()
        let name = "study"
        let newActivity = try await ActivityModel.create(
            .init(
                id: id,
                categoryId: category.id!,
                name: name,
                color: "#000000",
                icon: "",
                order: 1
            ),
            on: dbm.db
        )

        guard
            let found = try await ActivityModel
            .fetch(.init(id: id), on: dbm.db)
            .first
        else {
            return  XCTFail("")
        }

        XCTAssertTrue(newActivity.name == found.name)
        XCTAssertTrue(newActivity.color == found.color)
    }

    func testMove() async throws {
        guard
            let category = try await CategoryModel.query(on: dbm.db).first()
        else { throw AppError.notFound }

        let a = try await ActivityModel.fetch(on: dbm.db)

        let n1 = "sample1"
        let o1 = 1
        let new1 = try await ActivityModel.create(
            .init(
                id: UUID(),
                categoryId: category.id!,
                name: n1,
                color: "#000000",
                icon: "",
                order: o1
            ),
            on: dbm.db
        )

        let n2 = "sample2"
        let o2 = 2
        let new2 = try await ActivityModel.create(
            .init(
                id: UUID(),
                categoryId: category.id!,
                name: n2,
                color: "#000000",
                icon: "",
                order: o2
            ),
            on: dbm.db
        )

        let founds = try await ActivityModel.fetch(on: dbm.db)

        guard founds.count - a.count == 2 else { return  XCTFail("") }
        guard
            let found1 = founds.first(where: { $0.id == new1.id }),
            let found2 = founds.first(where: { $0.id == new2.id })
        else { return  XCTFail("")  }

        XCTAssertTrue(found1.name == n1 && found1.order == o1)
        XCTAssertTrue(found2.name == n2 && found2.order == o2)

        // move
        let service = ActivityService(db: dbm.db)
        try await service.updateOrder([founds[1].toData, founds[0].toData])

        let moved = try await ActivityModel.fetch(on: dbm.db)
        guard
            let moved1 = moved.first(where: { $0.id == new1.id }),
            let moved2 = moved.first(where: { $0.id == new2.id })
        else { return  XCTFail("")  }

//        XCTAssertTrue(moved1.name == n2 && moved1.order == o1)
//        XCTAssertTrue(moved2.name == n1 && moved2.order == o2)
    }

    func testToData() async throws {
        guard
            let category = try await CategoryModel.query(on: dbm.db).first()
        else { throw AppError.notFound }

        let name = "a"
        let color = "#000000"
        let service = ActivityService(db: dbm.db)
        let new = try await service.create(
            categoryId: category.id!,
            name: name,
            color: color,
            icon: ""
        )

        XCTAssertTrue(
            new.name == name
                && new.color == color
                && new.category?.name == category.name
        )
    }

    func testFetchEagerLoad() async throws {
        guard
            let category = try await CategoryModel.query(on: dbm.db).first()
        else { throw AppError.notFound }

        let a = try await ActivityModel
            .fetch(.init(categoryId: category.id!), on: dbm.db)

        let name = "sample"
        let color = "#000000"
        try await ActivityModel.create(
            .init(
                categoryId: category.id!,
                name: name,
                color: color,
                icon: "",
                order: 1
            ),
            on: dbm.db
        )

        let found = try await ActivityModel
            .fetch(.init(categoryId: category.id!), on: dbm.db)

        XCTAssertTrue(found.count - a.count == 1)
        XCTAssertTrue(found[0].$category.wrappedValue?.name == category.name)
    }
}
