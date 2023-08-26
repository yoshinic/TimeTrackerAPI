import Foundation
import FluentKit

extension RecordModel {
    static func create(
        _ data: CreateRecord,
        on db: Database
    ) async throws -> RecordModel {
        let newRecord = RecordModel(
            activityId: data.activityId,
            startedAt: data.startedAt,
            endedAt: data.startedAt
        )

        try await newRecord.create(on: db)

        return newRecord
    }

    static func fetch(
        _ data: FetchRecord? = nil,
        on db: Database
    ) async throws -> [RecordModel] {
        try await RecordModel
            .query(on: db)
            .join(parent: \.$activity)
            .group { and in
                guard let data = data else { return }
                if let recordId = data.recordId {
                    and.filter(\.$id == recordId)
                }
                if let activityId = data.activityId {
                    and.filter(\.$activity.$id == activityId)
                }
            }
            .all()
    }

    static func update(
        _ data: UpdateRecord,
        on db: Database
    ) async throws -> RecordModel {
        guard
            let found = try await RecordModel
            .query(on: db)
            .join(parent: \.$activity)
            .filter(\.$id == data.recordId)
            .first()
        else {
            throw AppError.notFound
        }

        if let activityId = data.activityId {
            found.$activity.id = activityId
        }
        found.startedAt = data.startedAt ?? found.startedAt
        found.endedAt = data.endedAt ?? found.endedAt

        try await found.update(on: db)

        return found
    }

    static func delete(
        _ data: DeleteRecord? = nil,
        on db: Database
    ) async throws {}
}

struct CreateRecord: Codable {
    let activityId: UUID
    let startedAt: Date
    let endedAt: Date
}

struct FetchRecord: Codable {
    let recordId: UUID?
    let activityId: UUID?
//    let startedAt: Date?
//    let endedAt: Date?
}

struct UpdateRecord: Codable {
    let recordId: UUID
    let activityId: UUID?
    let startedAt: Date?
    let endedAt: Date?
}

struct DeleteRecord: Codable {
    let recordId: UUID?
    let activityId: UUID?
    let startedAt: Date?
    let endedAt: Date?
}
