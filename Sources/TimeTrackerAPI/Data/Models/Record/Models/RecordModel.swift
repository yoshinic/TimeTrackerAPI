import Foundation
import Fluent

public final class RecordModel: Model {
    public static let schema = "records"

    enum FieldKeys {
        enum v1 {
            static var workId: FieldKey { "work_id" }
            static var startedAt: FieldKey { "started_at" }
            static var endedAt: FieldKey { "ended_at" }
        }
    }

    @ID()
    public var id: UUID?

    @Parent(key: FieldKeys.v1.workId)
    var work: WorkModel

    @Field(key: FieldKeys.v1.startedAt)
    var startedAt: Date

    @Field(key: FieldKeys.v1.endedAt)
    var endedAt: Date

    public init() {}

    init(
        _ id: RecordModel.IDValue? = nil,
        workId: WorkModel.IDValue,
        startedAt: Date,
        endedAt: Date
    ) {
        self.id = id
        self.$work.id = workId
        self.startedAt = startedAt
        self.endedAt = endedAt
    }
}
