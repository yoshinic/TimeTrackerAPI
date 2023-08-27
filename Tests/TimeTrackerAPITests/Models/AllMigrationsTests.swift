@testable import TimeTrackerAPI
import XCTest

final class AllMigrationsTests: XCTestCase {
    var dbm: TestDatabaseManager!

    override func setUp() async throws {
        try await super.setUp()
        dbm = TestDatabaseManager()
        try await AllMigrations.v1().prepare(on: dbm.database)
        try await AllMigrations.v1().revert(on: dbm.database)
    }

    override func tearDown() async throws {
        try await dbm.shutdown()
        dbm = nil
        
        try await super.tearDown()
    }

    func testMigration() async throws {
        try await AllMigrations.v1().prepare(on: dbm.database)
        try await AllMigrations.v1().revert(on: dbm.database)
    }

    func testMigrationWithSeed() async throws {
        try await AllMigrations.v1().prepare(on: dbm.database)
        try await AllMigrations.seed().prepare(on: dbm.database)

        try await AllMigrations.seed().revert(on: dbm.database)
        try await AllMigrations.v1().revert(on: dbm.database)
    }
}
