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
            .join(parent: \.$activity, method: .left)
            .join(from: ActivityModel.self, parent: \.$category, method: .left)
            .group { and in
                guard let data = data else { return }
                if let recordId = data.recordId {
                    and.filter(\.$id == recordId)
                }

                and.group(.or) { or in
                    data.categoryIds.forEach {
                        or.filter(CategoryModel.self, \.$id == $0)
                    }
                    data.activityIds.forEach {
                        or.filter(ActivityModel.self, \.$id == $0)
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

    @discardableResult
    static func update(
        _ data: UpdateRecord,
        on db: Database
    ) async throws -> RecordModel {
        guard
            let found = try await fetch(.init(recordId: data.recordId), on: db).first
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
    ) async throws {
        try await RecordModel
            .query(on: db)
            .group(.and) { and in
                guard let id = data?.id else { return }
                and.filter(\.$id == id)
            }
            .delete()
    }

    @discardableResult
    static func assignJoinedActivity(
        to record: RecordModel
    ) throws -> RecordModel  {
        do {
            record.$activity.value = try record.joined(ActivityModel.self)
        } catch {
            print(error)
        }
        do {
            try ActivityModel.assignJoinedCategory(to: record.$activity.wrappedValue)
        } catch {
            print(error)
        }
        return record
    }

    @discardableResult
    static func eagerLoad(
        to record: RecordModel,
        on db: Database
    ) async throws -> RecordModel  {
        try await record.$activity.load(on: db)
        try await record.activity?.$category.load(on: db)
        return record
    }
}

struct CreateRecord: Codable {
    let activityId: UUID?
    let startedAt: Date
    let endedAt: Date?
    let note: String
}

struct FetchRecord: Codable {
    let recordId: UUID?

    let fetchDateCase: FetchRecordDateCase
    let from: Date?
    let to: Date?

    let categoryIds: [UUID]
    let activityIds: [UUID]

    init(
        recordId: UUID? = nil,
        fetchDateCase: FetchRecordDateCase = .range,
        from: Date? = nil,
        to: Date? = nil,
        categoryIds: [UUID] = [],
        activityIds: [UUID] = []
    ) {
        self.recordId = recordId
        self.fetchDateCase = fetchDateCase
        self.from = from
        self.to = to
        self.categoryIds = categoryIds
        self.activityIds = activityIds
    }
}

struct UpdateRecord: Codable {
    let recordId: UUID
    let activityId: UUID?
    let startedAt: Date?
    let endedAt: Date?
    let note: String?

    init(
        recordId: UUID,
        activityId: UUID? = nil,
        startedAt: Date? = nil,
        endedAt: Date? = nil,
        note: String? = nil
    ) {
        self.recordId = recordId
        self.activityId = activityId
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.note = note
    }
}

struct DeleteRecord: Codable {
    let id: UUID?

    init(id: UUID? = nil) {
        self.id = id
    }
}

enum FetchRecordDateCase: Codable {
    case range
    case nullEnd
}
