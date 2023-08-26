@testable import TimeTrackerAPI
import XCTest
import FluentKit

// 参考
// https://github.com/vapor/fluent-sqlite-driver/blob/main/Tests/FluentSQLiteDriverTests/FluentSQLiteDriverTests.swift

class AbstractionXCTestCase: XCTestCase {
    var dbm: DatabaseManager!

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

        dbm = DatabaseManager()
    }

    override func tearDown() async throws {
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

    func migration(
        with closure: (Database) async throws -> Void
    ) async throws {
        try await AllMigrations.v1().prepare(on: dbm.database)
        try await AllMigrations.seed().prepare(on: dbm.database)

        try await closure(dbm.database)

        try await AllMigrations.v1().revert(on: dbm.database)
        //        try await AllMigrations.seed().revert(on: dbm.database)
    }
}
