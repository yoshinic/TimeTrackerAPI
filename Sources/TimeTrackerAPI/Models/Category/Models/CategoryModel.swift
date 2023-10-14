import Foundation
import Fluent

final class CategoryModel: Model {
    static let schema = "categories"

    static let `default`: CategoryData = .init(
        id: UUID(),
        name: "未登録",
        color: "#FFFFFF",
        order: 1
    )

    enum FieldKeys {
        enum v1 {
            static var name: FieldKey { "name" }
            static var color: FieldKey { "color" }
            static var order: FieldKey { "order" }
        }
    }

    @ID()
    var id: UUID?

    @Field(key: FieldKeys.v1.name)
    var name: String

    @Field(key: FieldKeys.v1.color)
    var color: String

    @Field(key: FieldKeys.v1.order)
    var order: Int

    @Children(for: \.$category)
    var activities: [ActivityModel]

    init() {}

    init(
        _ id: CategoryModel.IDValue? = nil,
        name: String,
        color: String,
        order: Int
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.order = order
    }
}
