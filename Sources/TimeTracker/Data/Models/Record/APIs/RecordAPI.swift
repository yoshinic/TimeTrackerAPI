import Foundation
import FluentKit

extension RecordModel {
    static func create(
        _ data: CreateRecord,
        on db: Database
    ) async throws -> RecordModel {
        let newRecord = RecordModel(
            workId: data.workId,
            startedAt: data.startedAt,
            endedAt: data.startedAt
        )

        try await newRecord.create(on: db)

        return newRecord
    }

    static func update(
        _ data: UpdateRecord,
        on db: Database
    ) async throws -> RecordModel {
        guard
            let foundRecord = try await RecordModel
            .query(on: db)
            .join(parent: \.$work)
            .filter(\.$id == data.recordId)
            .first()
        else {
            throw AppError.notFound
        }

        foundRecord.$work.id = data.workId
        foundRecord.startedAt = data.startedAt
        foundRecord.endedAt = data.endedAt

        try await foundRecord.update(on: db)

        return foundRecord
    }

    static func find(
        _ data: FindRecord,
        on db: Database
    ) async throws -> [RecordModel] {
        try await RecordModel
            .query(on: db)
            .join(parent: \.$work)
            .group { and in
                if let recordId = data.recordId {
                    and.filter(\.$id == recordId)
                }
                if let workId = data.workId {
                    and.filter(\.$work.$id == workId)
                }
            }
            .all()
    }
}

struct CreateRecord: Codable {
    let workId: WorkModel.IDValue
    let startedAt: Date
    let endedAt: Date
}

struct UpdateRecord: Codable {
    let recordId: RecordModel.IDValue
    let workId: WorkModel.IDValue
    let startedAt: Date
    let endedAt: Date
}

struct FindRecord: Codable {
    let recordId: RecordModel.IDValue?
    let workId: WorkModel.IDValue?
//    let startedAt: Date?
//    let endedAt: Date?
}
