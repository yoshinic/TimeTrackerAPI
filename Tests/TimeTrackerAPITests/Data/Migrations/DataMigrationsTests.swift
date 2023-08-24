@testable import TimeTrackerAPI
import XCTest

final class DataMigrationsTests: AbstractionXCTestCase {
    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    func testMigration() async throws {
        try await DataMigrations.v1().prepare(on: db)
        try await DataMigrations.v1().revert(on: db)
    }

    func testMigrationWithSeed() async throws {
        try await DataMigrations.v1().prepare(on: db)
        try await DataMigrations.seed().prepare(on: db)

        try await DataMigrations.seed().revert(on: db)
        try await DataMigrations.v1().revert(on: db)
    }
}
