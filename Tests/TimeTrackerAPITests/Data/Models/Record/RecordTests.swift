@testable import TimeTrackerAPI
import XCTest
import Foundation
import FluentKit

final class RecordTests: AbstractionXCTestCase {
    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    func testCreate() async throws {
        try await migration { db in

            let workName = "sample"

            let newWork = WorkModel(name: workName,color: "#000000")
            try await newWork.create(on: db)

            let newRecord = RecordModel(workId: newWork.id!, startedAt: Date(), endedAt: Date())
            try await newRecord.create(on: db)

            guard
                let found = try await RecordModel
                .query(on: db)
                .join(parent: \.$work)
                .first()
            else {
                return  XCTFail("")
            }

            let n = try found.joined(WorkModel.self).name

            XCTAssertTrue(n == workName)
        }
    }
}
