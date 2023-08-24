@testable import TimeTrackerAPI
import XCTest

final class MasterMigrationsTests: AbstractionXCTestCase {
    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    func testMigration() async throws {
        try await MasterMigrations.v1().prepare(on: db)
        try await MasterMigrations.v1().revert(on: db)
    }

    func testMigrationWithSeed() async throws {
        try await MasterMigrations.v1().prepare(on: db)
        try await MasterMigrations.seed().prepare(on: db)

        try await MasterMigrations.seed().revert(on: db)
        try await MasterMigrations.v1().revert(on: db)
    }
}
