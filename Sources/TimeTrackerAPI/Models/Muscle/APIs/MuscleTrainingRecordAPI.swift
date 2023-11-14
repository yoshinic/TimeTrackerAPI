import FluentKit
import Foundation

extension MuscleTrainingRecordModel {
    @discardableResult
    static func create(
        _ data: CreateMuscleTrainingRecord,
        on db: Database
    ) async throws -> MuscleTrainingRecordModel {
        let m = MuscleTrainingRecordModel(
            record: data.recordId,
            trainingRecord: data.trainingRecordId
        )
        try await m.create(on: db)
        return m
    }

    static func delete(
        _ data: DeleteMuscleTrainingRecord,
        on db: Database
    ) async throws {
        try await MuscleTrainingRecordModel
            .query(on: db)
            .filter(\.$record.$id == data.recordId)
            .filter(\.$trainingRecord.$id == data.trainingRecordId)
            .delete()
    }
}

struct CreateMuscleTrainingRecord: Codable {
    let recordId: UUID
    let trainingRecordId: UUID
    init(
        _ recordId: UUID,
        _ trainingRecordId: UUID
    ) {
        self.recordId = recordId
        self.trainingRecordId = trainingRecordId
    }
}

struct UpdateMuscleTrainingRecord: Codable {
    let recordId: UUID
    let trainingRecordId: UUID
    init(
        _ recordId: UUID,
        _ trainingRecordId: UUID
    ) {
        self.recordId = recordId
        self.trainingRecordId = trainingRecordId
    }
}

struct DeleteMuscleTrainingRecord: Codable {
    let recordId: UUID
    let trainingRecordId: UUID
    init(
        _ recordId: UUID,
        _ trainingRecordId: UUID
    ) {
        self.recordId = recordId
        self.trainingRecordId = trainingRecordId
    }
}
