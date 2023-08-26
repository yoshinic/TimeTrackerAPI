import Fluent

final class ActivityModel: Model {
    static let schema = "activities"

    enum FieldKeys {
        enum v1 {
            static var name: FieldKey { "name" }
            static var color: FieldKey { "color" }
        }
    }

    @ID()
    var id: UUID?

    @Field(key: FieldKeys.v1.name)
    var name: String

    @Field(key: FieldKeys.v1.color)
    var color: String

    @Children(for: \.$activity)
    var records: [RecordModel]

    init() {}

    init(
        _ id: ActivityModel.IDValue? = nil,
        name: String,
        color: String
    ) {
        self.id = id
        self.name = name
        self.color = color
    }
}
