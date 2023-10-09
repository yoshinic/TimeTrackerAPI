import Foundation
import FluentKit

public class RecordService {
    private let db: Database

    init(db: Database) {
        self.db = db
    }

    public func create(
        activityId: UUID,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        note: String = ""
    ) async throws -> RecordData {
        let new = try await RecordModel.create(
            .init(
                activityId: activityId,
                startedAt: startedAt,
                endedAt: endedAt ?? Date(),
                note: note
            ),
            on: db
        )

        return .init(
            id: new.id!,
            activity: .init(
                id: new.activity.id!,
                categoryId: new.activity.$category.id,
                name: new.activity.name,
                color: new.activity.color
            ),
            startedAt: new.startedAt,
            endedAt: new.endedAt,
            note: new.note
        )
    }

    public func fetch(
        recordId: UUID? = nil,
        from: Date? = nil,
        to: Date? = nil,
        activityIds: [UUID] = [],
        activityNames: [String] = [],
        activityColors: [String] = []
    ) async throws -> [RecordData] {
        let a = try await RecordModel.fetch(
            .init(
                recordId: recordId,
                from: from,
                to: to,
                activityIds: activityIds,
                activityNames: activityNames,
                activityColors: activityColors
            ),
            on: db
        )
        return a.map {
            .init(
                id: $0.id!,
                activity: .init(
                    id: $0.activity.id!,
                    categoryId: $0.activity.$category.id,
                    name: $0.activity.name,
                    color: $0.activity.color
                ),
                startedAt: $0.startedAt,
                endedAt: $0.endedAt,
                note: $0.note
            )
        }
    }

    public func update(
        recordId: UUID,
        activityId: UUID? = nil,
        startedAt: Date? = nil,
        endedAt: Date? = nil,
        note: String? = nil
    ) async throws -> RecordData {
        let updated = try await RecordModel.update(
            .init(
                recordId: recordId,
                activityId: activityId,
                startedAt: startedAt,
                endedAt: endedAt,
                note: note
            ),
            on: db
        )

        return .init(
            id: updated.id!,
            activity: .init(
                id: updated.activity.id!,
                categoryId: updated.activity.$category.id,
                name: updated.activity.name,
                color: updated.activity.color
            ),
            startedAt: updated.startedAt,
            endedAt: updated.endedAt,
            note: updated.note
        )
    }

    public func delete(
        recordId: UUID? = nil,
        activityId: UUID? = nil,
        startedAt: Date? = nil,
        endedAt: Date? = nil
    ) async throws {
        try await RecordModel.delete(
            .init(
                recordId: recordId,
                activityId: activityId,
                startedAt: startedAt,
                endedAt: endedAt
            ),
            on: db
        )
    }
}

public struct RecordData: Codable, Identifiable {
    public var id: UUID
    public let activity: ActivityData
    public let startedAt: Date
    public let endedAt: Date
    public let note: String

    public init(
        id: UUID,
        activity: ActivityData,
        startedAt: Date,
        endedAt: Date,
        note: String
    ) {
        self.id = id
        self.activity = activity
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.note = note
    }
}
