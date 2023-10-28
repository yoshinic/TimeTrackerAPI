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
        recordId: UUID? = nil,
        nullEnd: Bool = false,
        from: Date? = nil,
        to: Date? = nil,
        categoryIds: [UUID] = [],
        activityIds: [UUID] = []
    ) async throws -> [RecordData] {
        try await RecordModel
            .fetch(
                .init(
                    recordId: recordId,
                    fetchDateCase: nullEnd ? .nullEnd : .range,
                    from: from,
                    to: to,
                    categoryIds: categoryIds,
                    activityIds: activityIds
                ),
                on: db
            )
            .map { $0.toData }
    }

    public func update(
        recordId: UUID,
        activityId: UUID? = nil,
        startedAt: Date? = nil,
        endedAt: Date? = nil,
        note: String? = nil
    ) async throws -> RecordData {
        try await RecordModel
            .update(
                .init(
                    recordId: recordId,
                    activityId: activityId,
                    startedAt: startedAt,
                    endedAt: endedAt,
                    note: note
                ),
                on: db
            )
            .toData
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
