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
        try await dbm.setDatabase(filePath: "/Users/yoshi/Desktop/xxx.sqlite3")

        // dbm = TestDatabaseManager() でインスタンスが作成されるまで待機
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    override func tearDown() async throws {
        try await AllMigrations.seed().revert(on: dbm.db)
        try await AllMigrations.v1().revert(on: dbm.db)
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
