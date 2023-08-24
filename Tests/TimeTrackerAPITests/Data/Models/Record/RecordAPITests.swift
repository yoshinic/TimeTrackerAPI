@testable import TimeTrackerAPI
import XCTest
import Foundation

final class RecordAPITests: AbstractionXCTestCase {
    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    func testCreate() async throws {
        try await migration { db in

            let workName = "sample"

            let newWork = try await WorkModel.create(.init(name: workName, color: "#000000"), on: db)

            let newRecord = try await RecordModel.create(
                .init(workId: newWork.id!, startedAt: Date(), endedAt: Date()),
                on: db
            )

            let founds = try await RecordModel
                .find(.init(recordId: newRecord.requireID(), workId: newWork.requireID()), on: db)

            guard founds.count == 1 else { return  XCTFail("") }

            let n = try founds[0].joined(WorkModel.self).name

            XCTAssertTrue(n == workName)
        }
    }
}
