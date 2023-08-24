@testable import TimeTracker
import XCTest
import Foundation
import FluentKit

final class WorkTests: AbstractionXCTestCase {
    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    func testCreate() async throws {
        try await migration { db in

            let name = "study"

            let newWork = WorkModel(name: name,color: "#000000")
            try await newWork.create(on: db)

            guard
                let found = try await WorkModel
                .query(on: db)
                .filter(\.$name == name)
                .first()
            else {
                return  XCTFail("")
            }

            XCTAssertTrue(found.name == name)
        }
    }
}
