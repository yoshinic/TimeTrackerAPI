import Foundation
import FluentKit

public class RecordService {
    private let db: Database

    init(db: Database) {
        self.db = db
    }

    public func create(
        activityId: UUID?,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        note: String = ""
    ) async throws -> RecordData {
        try await RecordModel
            .create(
                .init(
                    activityId: activityId,
                    startedAt: startedAt,
                    endedAt: endedAt,
                    note: note
                ),
                on: db
            )
            .toData
    }

    public func fetch(
        id: UUID? = nil,
        categories: Set<UUID> = [],
        activities: Set<UUID> = [],
        nullEnd: Bool = false,
        from: Date? = nil,
        to: Date? = nil
    ) async throws -> [RecordData] {
        try await RecordModel
            .fetch(
                .init(
                    id: id,
                    categories: categories,
                    activities: activities,
                    from: from,
                    to: to
                ),
                on: db
            )
            .map { $0.toData }
    }

    public func update(
        id: UUID,
        activityId: UUID?,
        startedAt: Date,
        endedAt: Date?,
        note: String
    ) async throws -> RecordData {
        try await RecordModel
            .update(
                .init(
                    id: id,
                    activityId: activityId,
                    startedAt: startedAt,
                    endedAt: endedAt,
                    note: note
                ),
                on: db
            )
            .toData
    }

    public func delete(id: UUID? = nil) async throws {
        try await RecordModel.delete(
            .init(id: id),
            on: db
        )
    }
}

public struct RecordData: Codable, Identifiable {
    public var id: UUID
    public let activity: ActivityData?
    public let startedAt: Date
    public let endedAt: Date?
    public let note: String

    public init(
        id: UUID,
        activity: ActivityData?,
        startedAt: Date,
        endedAt: Date?,
        note: String
    ) {
        self.id = id
        self.activity = activity
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.note = note
    }
}

extension RecordData: Hashable {}

extension RecordModel {
    var toData: RecordData {
        RecordData(
            id: self.id!,
            activity: self.$activity.wrappedValue?.toData,
            startedAt: self.startedAt,
            endedAt: self.endedAt,
            note: self.note
        )
    }
}
