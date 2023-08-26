@testable import TimeTrackerAPI
import XCTest
import SQLKit
import FluentKit
import SQLiteNIO

final class DatabaseTests: AbstractionXCTestCase {
    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    func testDatabase() async throws {
        let sql = (dbm.database as! SQLDatabase)

        do {
            try await sql.raw("asdf").run()
        } catch let error as DatabaseError where error.isSyntaxError {
            // pass
        } catch {
            XCTFail("\(error)")
        }

        do {
            try await sql.raw("CREATE TABLE foo (name TEXT UNIQUE)").run()
            try await sql.raw("INSERT INTO foo (name) VALUES ('bar')").run()
            try await sql.raw("INSERT INTO foo (name) VALUES ('bar')").run()
        } catch let error as DatabaseError where error.isConstraintFailure {
            // pass
        } catch {
            XCTFail("\(error)")
        }

        _ = (sql as! SQLiteDatabase).withConnection { conn in
            conn.close().flatMap {
                conn.sql().raw("INSERT INTO foo (name) VALUES ('bar')").run()
            }
        }
    }
}
