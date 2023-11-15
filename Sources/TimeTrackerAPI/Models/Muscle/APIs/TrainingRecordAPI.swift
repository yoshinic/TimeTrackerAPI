import FluentKit
import Foundation

extension TrainingRecordModel {
    @discardableResult
    static func create(
        _ id: UUID? = nil,
        data: CreateTrainingRecord,
        on db: Database
    ) async throws -> TrainingRecordModel {
        let m = TrainingRecordModel(
            menuId: data.menuId,
            startedAt: data.startedAt,
            endedAt: data.endedAt,
            set: data.set,
            weight: data.weight,
            number: data.number,
            speed: data.speed,
            duration: data.duration,
            slope: data.slope,
            note: data.note
        )
        try await m.create(on: db)

        return m
    }

    @discardableResult
    static func update(
        _ data: UpdateTrainingRecord,
        on db: Database
    ) async throws -> TrainingRecordModel {
        guard
            let found = try await TrainingRecordModel.find(data.id, on: db)
        else { throw AppError.notFound }

        found.$menu.id = data.menuId
        found.startedAt = data.startedAt
        found.endedAt = data.endedAt
        found.set = data.set
        found.weight = data.weight
        found.number = data.number
        found.speed = data.speed
        found.duration = data.duration
        found.slope = data.slope
        found.note = data.note

        try await found.update(on: db)

        return found
    }

    static func fetch(
        _ data: FetchTrainingRecord? = nil,
        on db: Database
    ) async throws -> [TrainingRecordModel] {
        try await TrainingRecordModel
            .query(on: db)
            .join(parent: \.$menu)
            .join(from: TrainingMenuModel.self, parent: \.$mainPart)
            .join(children: \.$muscleTrainingRecords)
            .join(from: MuscleTrainingRecordModel.self, parent: \.$record)
            .group(.and) { and in
                guard let data = data else { return }

                if let _ = data.ids.first {
                    and.filter(\.$id ~~ data.ids)
                }
                if let _ = data.recordIds.first {
                    and.filter(RecordModel.self, \.$id ~~ data.recordIds)
                }
                if let _ = data.menuIds.first {
                    and.filter(\.$menu.$id ~~ data.menuIds)
                }

                if let from = data.from, let to = data.to {
                    and.group(.or) { or in
                        or.group(.and) { and in
                            and.filter(RecordModel.self, \.$startedAt < from)
                            and.group(.or) { or in
                                or
                                    .filter(RecordModel.self, \.$endedAt > from)
                                    .filter(RecordModel.self, \.$endedAt == nil)
                            }
                        }
                        or.group(.and) { and in
                            and
                                .filter(RecordModel.self, \.$startedAt >= from)
                                .filter(RecordModel.self, \.$startedAt < to)
                        }
                    }
                } else if let from = data.from {
                    and.group(.or) { or in
                        or.group(.and) { and in
                            and.filter(RecordModel.self, \.$startedAt < from)
                            and.group(.or) { or in
                                or
                                    .filter(RecordModel.self, \.$endedAt > from)
                                    .filter(RecordModel.self, \.$endedAt == nil)
                            }
                        }
                        or.filter(RecordModel.self, \.$startedAt >= from)
                    }
                } else if let to = data.to {
                    and.filter(RecordModel.self, \.$startedAt < to)
                }
            }
            .all()
    }

    static func delete(
        _ data: DeleteTrainingRecord,
        on db: Database
    ) async throws {
        try await TrainingRecordModel
            .query(on: db)
            .filter(\.$id ~~ data.ids)
            .delete()
    }
}

struct CreateTrainingRecord {
    let menuId: UUID
    let startedAt: Date?
    let endedAt: Date?
    let set: Int
    let weight: Float
    let number: Int
    let speed: Float
    let duration: Float
    let slope: Float
    let note: String
}

struct UpdateTrainingRecord {
    let id: UUID
    let menuId: UUID
    let startedAt: Date?
    let endedAt: Date?
    let set: Int
    let weight: Float
    let number: Int
    let speed: Float
    let duration: Float
    let slope: Float
    let note: String
}

struct FetchTrainingRecord {
    let ids: Set<UUID>
    let recordIds: Set<UUID>
    let menuIds: Set<UUID>
    let from: Date?
    let to: Date?

    init(
        ids: Set<UUID> = [],
        recordIds: Set<UUID> = [],
        menuIds: Set<UUID> = [],
        from: Date? = nil,
        to: Date? = nil
    ) {
        self.ids = ids
        self.recordIds = recordIds
        self.menuIds = menuIds
        self.from = from
        self.to = to
    }
}

struct DeleteTrainingRecord {
    let ids: Set<UUID>
}
