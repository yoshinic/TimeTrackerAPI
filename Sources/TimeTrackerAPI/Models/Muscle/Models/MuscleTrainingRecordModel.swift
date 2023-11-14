import FluentKit
import Foundation

final class MuscleTrainingRecordModel: Model {
    static let schema = "muscle_training_records"

    enum FieldKeys {
        enum v1 {
            static var recordId: FieldKey { "record_id" }
            static var trainingRecordId: FieldKey { "trainingRecord_id" }
        }
    }

    @ID()
    var id: UUID?

    @Parent(key: FieldKeys.v1.recordId)
    var record: RecordModel

    @Parent(key: FieldKeys.v1.trainingRecordId)
    var trainingRecord: TrainingRecordModel

    init() {}

    init(
        _ id: MuscleTrainingRecordModel.IDValue? = nil,
        record: RecordModel.IDValue,
        trainingRecord: TrainingRecordModel.IDValue
    ) {
        self.id = id
        self.$record.id = record
        self.$trainingRecord.id = trainingRecord
    }
}
