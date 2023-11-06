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

                if let id = data.id {
                    and.filter(\.$id == id)
                }

                and.group(.or) { or in
                    data.categories.forEach {
                        or.filter(CategoryModel.self, \.$id == $0)
                    }
                    data.activities.forEach {
                        or.filter(ActivityModel.self, \.$id == $0)
                    }
                }

                if let from = data.from, let to = data.to {
                    and.group(.or) { or in
                        or.group(.and) { and in
                            and.filter(\.$startedAt < from)
                            and.group(.or) { or in
                                or.filter(\.$endedAt > from).filter(\.$endedAt == nil)
                            }
                        }
                        or.group(.and) { and in
                            and.filter(\.$startedAt >= from).filter(\.$startedAt < to)
                        }
                    }
                } else if let from = data.from {
                    and.group(.or) { or in
                        or.group(.and) { and in
                            and.filter(\.$startedAt < from)
                            and.group(.or) { or in
                                or.filter(\.$endedAt > from).filter(\.$endedAt == nil)
                            }
                        }
                        or.filter(\.$startedAt >= from)
                    }
                } else if let to = data.to {
                    and.filter(\.$startedAt < to)
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
            let found = try await fetch(.init(id: data.id), on: db).first
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
    let id: UUID?
    let categories: Set<UUID>
    let activities: Set<UUID>
    let from: Date?
    let to: Date?

    init(
        id: UUID? = nil,
        categories: Set<UUID> = [],
        activities: Set<UUID> = [],
        from: Date? = nil,
        to: Date? = nil
    ) {
        self.id = id
        self.categories = categories
        self.activities = activities
        self.from = from
        self.to = to
    }
}

struct UpdateRecord: Codable {
    let id: UUID
    let activityId: UUID?
    let startedAt: Date?
    let endedAt: Date?
    let note: String?

    init(
        id: UUID,
        activityId: UUID? = nil,
        startedAt: Date? = nil,
        endedAt: Date? = nil,
        note: String? = nil
    ) {
        self.id = id
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
