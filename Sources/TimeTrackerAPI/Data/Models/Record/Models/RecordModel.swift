import Foundation
import Fluent

public final class RecordModel: Model {
    public static let schema = "records"

    enum FieldKeys {
        enum v1 {
            static var activityId: FieldKey { "activity_id" }
            static var startedAt: FieldKey { "started_at" }
            static var endedAt: FieldKey { "ended_at" }
        }
    }

    @ID()
    public var id: UUID?

    @Parent(key: FieldKeys.v1.activityId)
    var activity: ActivityModel

    @Field(key: FieldKeys.v1.startedAt)
    var startedAt: Date

    @Field(key: FieldKeys.v1.endedAt)
    var endedAt: Date

    public init() {}

    init(
        _ id: RecordModel.IDValue? = nil,
        activityId: ActivityModel.IDValue,
        startedAt: Date,
        endedAt: Date
    ) {
        self.id = id
        self.$activity.id = activityId
        self.startedAt = startedAt
        self.endedAt = endedAt
    }
}
