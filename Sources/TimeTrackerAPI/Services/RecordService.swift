import Foundation
import FluentKit

class RecordService {
    private let db: Database

    init(db: Database) {
        self.db = db
    }

    func create(
        activityId: ActivityModel.IDValue,
        startedAt: Date = Date(),
        endedAt: Date? = nil
    ) async throws -> RecordModel {
        try await RecordModel.create(
            .init(
                activityId: activityId,
                startedAt: startedAt,
                endedAt: endedAt ?? Date()
            ),
            on: db
        )
    }

    func fetch(
        recordId: RecordModel.IDValue?,
        activityId: ActivityModel.IDValue?
    ) async throws -> [RecordModel] {
        try await RecordModel.fetch(
            .init(recordId: recordId, activityId: activityId),
            on: db
        )
    }

    func update(
        recordId: RecordModel.IDValue,
        activityId: ActivityModel.IDValue? = nil,
        startedAt: Date? = nil,
        endedAt: Date? = nil
    ) async throws -> RecordModel {
        try await RecordModel.update(
            .init(
                recordId: recordId,
                activityId: activityId,
                startedAt: startedAt,
                endedAt: endedAt
            ),
            on: db
        )
    }

    func delete(
        recordId: RecordModel.IDValue? = nil,
        activityId: ActivityModel.IDValue? = nil,
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
