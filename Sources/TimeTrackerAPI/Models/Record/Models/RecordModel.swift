import Foundation
import Fluent

final class RecordModel: Model {
    static let schema = "records"

    enum FieldKeys {
        enum v1 {
            static var activityId: FieldKey { "activity_id" }
            static var startedAt: FieldKey { "started_at" }
            static var endedAt: FieldKey { "ended_at" }
            static var note: FieldKey { "note" }
        }
    }

    @ID()
    var id: UUID?

    @Parent(key: FieldKeys.v1.activityId)
    var activity: ActivityModel

    @Field(key: FieldKeys.v1.startedAt)
    var startedAt: Date

    @OptionalField(key: FieldKeys.v1.endedAt)
    var endedAt: Date?
    
    @Field(key: FieldKeys.v1.note)
    var note: String

    init() {}

    init(
        _ id: RecordModel.IDValue? = nil,
        activityId: ActivityModel.IDValue,
        startedAt: Date,
        endedAt: Date?,
        note: String
    ) {
        self.id = id
        self.$activity.id = activityId
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.note = note
    }
}
