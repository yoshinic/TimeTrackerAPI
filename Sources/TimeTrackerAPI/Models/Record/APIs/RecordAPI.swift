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
            endedAt: data.endedAt,
            note: data.note
        )

        try await newRecord.create(on: db)
        try await eagerLoad(to: newRecord, on: db)
        return newRecord
    }

    static func fetch(
        _ data: FetchRecord? = nil,
        on db: Database
    ) async throws -> [RecordModel] {
        try await RecordModel
            .query(on: db)
            .join(parent: \.$activity)
            .join(from: ActivityModel.self, parent: \.$category)
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

                switch data.fetchDateCase {
                case .range:
                    if let from = data.from {
                        and.filter(\.$startedAt >= from)
                    }
                    if let to = data.to {
                        and.filter(\.$endedAt <= to)
                    }
                case .nullEnd:
                    and.filter(\.$endedAt == nil)
                }
            }
            .all()
            .map { try assignJoinedActivity(to: $0) }
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
        if let startedAt = data.startedAt {
            found.startedAt = startedAt
        }
        if let endedAt = data.endedAt {
            found.endedAt = endedAt
        }
        if let note = data.note {
            found.note = note
        }

        try await found.update(on: db)
        try await eagerLoad(to: found, on: db)
        return found
    }

    static func delete(
        _ data: DeleteRecord? = nil,
        on db: Database
    ) async throws {}

    @discardableResult
    static func assignJoinedActivity(
        to record: RecordModel
    ) throws -> RecordModel  {
        record.$activity.value = try record.joined(ActivityModel.self)
        try ActivityModel.assignJoinedCategory(to: record.$activity.value!)
        return record
    }

    @discardableResult
    static func eagerLoad(
        to record: RecordModel,
        on db: Database
    ) async throws -> RecordModel  {
        try await record.$activity.load(on: db)
        try await record.activity.$category.load(on: db)
        return record
    }
}

struct CreateRecord: Codable {
    let activityId: UUID
    let startedAt: Date
    let endedAt: Date?
    let note: String
}

struct FetchRecord: Codable {
    let recordId: UUID?

    let fetchDateCase: FetchRecordDateCase
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
    let note: String?
}

struct DeleteRecord: Codable {
    let recordId: UUID?
    let activityId: UUID?
    let startedAt: Date?
    let endedAt: Date?
}

enum FetchRecordDateCase: Codable {
    case range
    case nullEnd
}
