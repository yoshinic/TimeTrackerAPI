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

                and.group(.or) { or in
                    data.activityIds.forEach {
                        or.filter(ActivityModel.self, \.$id == $0)
                    }
                }
                and.group(.or) { or in
                    data.activityNames.forEach {
                        or.filter(ActivityModel.self, \.$name == $0)
                    }
                }
                and.group(.or) { or in
                    data.activityColors.forEach {
                        or.filter(ActivityModel.self, \.$color == $0)
                    }
                }

                if let from = data.from {
                    and.filter(\.$startedAt == from)
                }
                if let to = data.to {
                    and.filter(\.$endedAt == to)
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
    let from: Date?
    let to: Date?

    let activityIds: [UUID]
    let activityNames: [String]
    let activityColors: [String]
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
