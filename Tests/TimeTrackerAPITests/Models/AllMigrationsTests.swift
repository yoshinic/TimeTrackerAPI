@testable import TimeTrackerAPI
import XCTest

final class AllMigrationsTests: XCTestCase {
    var dbm: TestDatabaseManager!

    override func setUp() async throws {
        try await super.setUp()
        dbm = TestDatabaseManager()
        try await dbm.setDatabase()
        try await AllMigrations.v1().prepare(on: dbm.db)
        try await AllMigrations.v1().revert(on: dbm.db)
    }

    override func tearDown() async throws {
        try await dbm.shutdown()
        dbm = nil
        
        try await super.tearDown()
    }

    func testMigration() async throws {
        try await AllMigrations.v1().prepare(on: dbm.db)
        try await AllMigrations.v1().revert(on: dbm.db)
    }

    func testMigrationWithSeed() async throws {
        try await AllMigrations.v1().prepare(on: dbm.db)
        try await AllMigrations.seed().prepare(on: dbm.db)

        try await AllMigrations.seed().revert(on: dbm.db)
        try await AllMigrations.v1().revert(on: dbm.db)
    }
}
