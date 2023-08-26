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
        endedAt: Date? = nil
    ) async throws -> RecordData {
        let new = try await RecordModel.create(
            .init(
                activityId: activityId,
                startedAt: startedAt,
                endedAt: endedAt ?? Date()
            ),
            on: db
        )
        return .init(
            id: new.id!,
            activityId: new.activity.id!,
            startedAt: new.startedAt,
            endedAt: new.endedAt
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
                activityId: $0.activity.id!,
                startedAt: $0.startedAt,
                endedAt: $0.endedAt
            )
        }
    }

    public func update(
        recordId: UUID,
        activityId: UUID? = nil,
        startedAt: Date? = nil,
        endedAt: Date? = nil
    ) async throws -> RecordData {
        let updated = try await RecordModel.update(
            .init(
                recordId: recordId,
                activityId: activityId,
                startedAt: startedAt,
                endedAt: endedAt
            ),
            on: db
        )
        return .init(
            id: updated.id!,
            activityId: updated.activity.id!,
            startedAt: updated.startedAt,
            endedAt: updated.endedAt
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
    public let activityId: UUID
    public let startedAt: Date
    public let endedAt: Date
}
