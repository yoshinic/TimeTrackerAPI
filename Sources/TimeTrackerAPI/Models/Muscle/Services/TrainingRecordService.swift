import FluentKit
import Foundation

public class TrainingRecordService {
    private let db: Database

    init(db: Database) {
        self.db = db
    }

    public func create(
        _ id: UUID? = nil,
        recordId: UUID,
        menuId: UUID,
        startedAt: Date?,
        endedAt: Date?,
        set: Int,
        weight: Float,
        number: Int,
        speed: Float,
        duration: Float,
        slope: Float,
        note: String
    ) async throws -> TrainingRecordData {
        let trainingRecord = try await TrainingRecordModel.create(
            id,
            data: .init(
                menuId: menuId,
                startedAt: startedAt,
                endedAt: endedAt,
                set: set,
                weight: weight,
                number: number,
                speed: speed,
                duration: duration,
                slope: slope,
                note: note
            ),
            on: db
        )

        try await MuscleTrainingRecordModel.create(
            .init(recordId, trainingRecord.id!),
            on: db
        )

        return TrainingRecordData(
            id: trainingRecord.id!,
            recordId: recordId,
            menuId: menuId,
            startedAt: startedAt,
            endedAt: endedAt,
            set: set,
            weight: weight,
            number: number,
            speed: speed,
            duration: duration,
            slope: slope,
            note: note
        )
    }

    public func update(
        id: UUID,
        recordId: UUID,
        menuId: UUID,
        startedAt: Date?,
        endedAt: Date?,
        set: Int,
        weight: Float,
        number: Int,
        speed: Float,
        duration: Float,
        slope: Float,
        note: String
    ) async throws -> TrainingRecordData {
        guard
            let found = try await TrainingRecordModel
            .fetch(.init(ids: [id]), on: db)
            .first
        else { throw AppError.notFound }

        found.$menu.id = menuId
        found.startedAt = startedAt
        found.endedAt = endedAt
        found.set = set
        found.weight = weight
        found.number = number
        found.speed = speed
        found.duration = duration
        found.slope = slope
        found.note = note

        try await found.update(on: db)

        return .init(
            id: id,
            recordId: recordId,
            menuId: menuId,
            startedAt: startedAt,
            endedAt: endedAt,
            set: set,
            weight: weight,
            number: number,
            speed: speed,
            duration: duration,
            slope: slope,
            note: note
        )
    }

    public func fetch(
        ids: Set<UUID> = [],
        recordIds: Set<UUID> = [],
        from: Date? = nil,
        to: Date? = nil,
        menuIds: Set<UUID> = []
    ) async throws -> [TrainingRecordData] {
        try await TrainingRecordModel
            .fetch(
                .init(
                    ids: ids,
                    recordIds: recordIds,
                    menuIds: menuIds,
                    from: from,
                    to: to
                ),
                on: db
            )
            .map {
                try .init(
                    id: $0.id!,
                    recordId: $0.joined(RecordModel.self).id!,
                    menuId: $0.$menu.id,
                    startedAt: $0.startedAt,
                    endedAt: $0.endedAt,
                    set: $0.set,
                    weight: $0.weight,
                    number: $0.number,
                    speed: $0.speed,
                    duration: $0.duration,
                    slope: $0.slope,
                    note: $0.note
                )
            }
    }

    public func delete(
        recordId: UUID,
        trainingRecordId: UUID
    ) async throws {
        try await MuscleTrainingRecordModel
            .delete(.init(recordId, trainingRecordId), on: db)
        try await TrainingRecordModel
            .delete(.init(ids: [trainingRecordId]), on: db)
    }
}

public struct TrainingRecordData: Codable, Hashable, Identifiable {
    public let id: UUID
    public let recordId: UUID
    public let menuId: UUID
    public let startedAt: Date?
    public let endedAt: Date?
    public let set: Int
    public let weight: Float
    public let number: Int
    public let speed: Float
    public let duration: Float
    public let slope: Float
    public let note: String
}
