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
        try await db.transaction { db in
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

            guard
                let found = try await TrainingRecordModel
                .fetch(.init(ids: [trainingRecord.id!]), on: db)
                .first
            else { throw AppError.notFound }

            return try TrainingRecordData(
                id: trainingRecord.id!,
                recordId: recordId,
                menu: .init(
                    id: found.$menu.id,
                    name: found.joined(TrainingMenuModel.self).name,
                    mainPart: .init(
                        id: found.joined(MusclePartModel.self).requireID(),
                        name: found.joined(MusclePartModel.self).name,
                        order: found.joined(MusclePartModel.self).order
                    ),
                    aerobic: found.joined(TrainingMenuModel.self).aerobic,
                    order: found.joined(TrainingMenuModel.self).order
                ),
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
        try await db.transaction { db in
            guard
                let found = try await TrainingRecordModel.update(.init(
                    id: id,
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
                on: db)
            else { throw AppError.notFound }

            return try .init(
                id: id,
                recordId: recordId,
                menu: .init(
                    id: found.$menu.id,
                    name: found.joined(TrainingMenuModel.self).name,
                    mainPart: .init(
                        id: found.joined(MusclePartModel.self).requireID(),
                        name: found.joined(MusclePartModel.self).name,
                        order: found.joined(MusclePartModel.self).order
                    ),
                    aerobic: found.joined(TrainingMenuModel.self).aerobic,
                    order: found.joined(TrainingMenuModel.self).order
                ),
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
    }

    public func fetch(
        ids: Set<UUID> = [],
        recordIds: Set<UUID> = [],
        menuIds: Set<UUID> = [],
        from: Date? = nil,
        to: Date? = nil
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
                    menu: .init(
                        id: $0.$menu.id,
                        name: $0.joined(TrainingMenuModel.self).name,
                        mainPart: .init(
                            id: $0.joined(MusclePartModel.self).requireID(),
                            name: $0.joined(MusclePartModel.self).name,
                            order: $0.joined(MusclePartModel.self).order
                        ),
                        aerobic: $0.joined(TrainingMenuModel.self).aerobic,
                        order: $0.joined(TrainingMenuModel.self).order
                    ),
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
        try await db.transaction { db in
            try await MuscleTrainingRecordModel
                .delete(.init(recordId, trainingRecordId), on: db)
            try await TrainingRecordModel
                .delete(.init(ids: [trainingRecordId]), on: db)
        }
    }
}

public struct TrainingRecordData: Codable, Hashable, Identifiable {
    public let id: UUID
    public let recordId: UUID
    public let menu: TrainingMenuData
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

public struct TrainingMenuData: Codable, Hashable, Identifiable {
    public let id: UUID
    public let name: String
    public let mainPart: MusclePartData
    public let aerobic: Bool
    public let order: Int
}

public struct MusclePartData: Codable, Hashable, Identifiable {
    public let id: UUID
    public let name: String
    public let order: Int
}
