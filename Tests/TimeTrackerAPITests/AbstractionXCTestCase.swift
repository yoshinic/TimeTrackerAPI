@testable import TimeTrackerAPI
import XCTest
import Fluent

class AbstractionXCTestCase: XCTestCase {
    var dbm: TestDatabaseManager!

    override func setUp() async throws {
        try await super.setUp()

        if
            let envStorage = ProcessInfo.processInfo.environment["DATABASE_STORAGE"],
            let envFilePath = ProcessInfo.processInfo.environment["DATABASE_FILEPATH"],
            envStorage == "file",
            FileManager.default.fileExists(atPath: envFilePath)
        {
            try FileManager.default.removeItem(atPath: envFilePath)
        }

        dbm = TestDatabaseManager()
        try await AllMigrations.v1().prepare(on: dbm.database)
        try await AllMigrations.seed().prepare(on: dbm.database)
    }

    override func tearDown() async throws {
        try await AllMigrations.v1().revert(on: dbm.database)
        // try await AllMigrations.seed().revert(on: dbm.database)
        try await dbm.shutdown()
        dbm = nil

        if
            let envStorage = ProcessInfo.processInfo.environment["DATABASE_STORAGE"],
            let envFilePath = ProcessInfo.processInfo.environment["DATABASE_FILEPATH"],
            let fileDisposal = Bool(ProcessInfo.processInfo.environment["DATABASE_FILEDISPOSAL"] ?? "false"),
            envStorage == "file",
            fileDisposal
        {
            try FileManager.default.removeItem(atPath: envFilePath)
        }

        try await super.tearDown()
    }
}

final class TestDatabaseManager: _DatabaseManager {}
