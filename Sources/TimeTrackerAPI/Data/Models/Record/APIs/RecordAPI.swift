import Foundation
import FluentKit

public extension RecordModel {
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

    static func update(
        _ data: UpdateRecord,
        on db: Database
    ) async throws -> RecordModel {
        guard
            let foundRecord = try await RecordModel
            .query(on: db)
            .join(parent: \.$activity)
            .filter(\.$id == data.recordId)
            .first()
        else {
            throw AppError.notFound
        }

        foundRecord.$activity.id = data.activityId
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
            .join(parent: \.$activity)
            .group { and in
                if let recordId = data.recordId {
                    and.filter(\.$id == recordId)
                }
                if let activityId = data.activityId {
                    and.filter(\.$activity.$id == activityId)
                }
            }
            .all()
    }
}

public struct CreateRecord: Codable {
    let activityId: ActivityModel.IDValue
    let startedAt: Date
    let endedAt: Date
}

public struct UpdateRecord: Codable {
    let recordId: RecordModel.IDValue
    let activityId: ActivityModel.IDValue
    let startedAt: Date
    let endedAt: Date
}

public struct FindRecord: Codable {
    let recordId: RecordModel.IDValue?
    let activityId: ActivityModel.IDValue?
//    let startedAt: Date?
//    let endedAt: Date?
}
